#!/usr/bin/env python3
"""CI-only Android signing configuration and Google Play version allocation.

Never prints secret values. Play inspection uses a temporary, uncommitted edit;
actual release upload is performed by the pinned upload-google-play action.
"""
import argparse
import base64
import binascii
import json
import os
from pathlib import Path
import re
import sys

APP = Path(__file__).resolve().parents[1]
PACKAGE = "asak.pro.pinPotha"
MAX_VERSION_CODE = 2_100_000_000
SECRET_NAMES = (
    "ANDROID_KEYSTORE_BASE64", "ANDROID_KEYSTORE_PASSWORD",
    "ANDROID_KEY_ALIAS", "ANDROID_KEY_PASSWORD", "GOOGLE_PLAY_SERVICE_ACCOUNT_JSON",
)


def closed_track(value):
    track = value.strip()
    if not re.fullmatch(r"[A-Za-z0-9_.:-]{1,100}", track):
        raise ValueError("GOOGLE_PLAY_CLOSED_TRACK must be a single track ID")
    if track.rsplit(":", 1)[-1].lower() in {"production", "beta", "internal", "internalsharing"}:
        raise ValueError("Only alpha or a custom closed-testing track is allowed")
    return track


def java_property(value):
    escaped = []
    special = {"\\": "\\\\", "\n": r"\n", "\r": r"\r", "\t": r"\t", " ": r"\ ", "=": r"\=", ":": r"\:"}
    for char in value:
        if char in special:
            escaped.append(special[char])
        elif ord(char) < 32 or ord(char) > 126:
            encoded = char.encode("utf-16-be")
            escaped.extend("\\u" + encoded[index:index+2].hex() for index in range(0, len(encoded), 2))
        else:
            escaped.append(char)
    return "".join(escaped)


def output(name, value, env):
    with Path(env["GITHUB_OUTPUT"]).open("a", encoding="utf-8") as handle:
        handle.write(f"{name}={value}\n")


def prepare(env, app=APP):
    missing = [name for name in SECRET_NAMES if not env.get(name)]
    if missing:
        raise ValueError("Missing GitHub Actions secrets: " + ", ".join(missing))
    track = closed_track(env.get("GOOGLE_PLAY_CLOSED_TRACK", "alpha"))
    try:
        account = json.loads(env["GOOGLE_PLAY_SERVICE_ACCOUNT_JSON"])
    except (TypeError, json.JSONDecodeError):
        raise ValueError("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON must contain valid JSON") from None
    if not isinstance(account, dict) or account.get("type") != "service_account" or not all(account.get(key) for key in ("client_email", "private_key", "token_uri")):
        raise ValueError("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON is not a service-account key")
    # Avoid allowing credential material to redirect OAuth token requests.
    if account["token_uri"] != "https://oauth2.googleapis.com/token":
        raise ValueError("Unexpected service-account token endpoint")
    match = re.search(r"^version:\s*([^\s+]+)(?:\+(\d+))?\s*$", (app / "pubspec.yaml").read_text(), re.MULTILINE)
    if not match:
        raise ValueError("pubspec.yaml is missing a valid version")
    version_name = env.get("ANDROID_VERSION_NAME", "").strip() or match[1]
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._+-]{0,99}", version_name):
        raise ValueError("ANDROID_VERSION_NAME contains unsupported characters")
    floor_text = env.get("ANDROID_VERSION_CODE_FLOOR", "").strip() or match[2] or "0"
    if not floor_text.isdecimal() or int(floor_text) >= MAX_VERSION_CODE:
        raise ValueError("ANDROID_VERSION_CODE_FLOOR must be between 0 and 2099999999")
    try:
        key = base64.b64decode("".join(env["ANDROID_KEYSTORE_BASE64"].split()), validate=True)
    except (ValueError, binascii.Error):
        raise ValueError("ANDROID_KEYSTORE_BASE64 is not valid base64") from None
    if not key:
        raise ValueError("ANDROID_KEYSTORE_BASE64 is empty after decoding")
    key_path = Path(env["RUNNER_TEMP"]) / "pinpotha-upload.jks"
    properties = app / "android/key.properties"
    if key_path.exists() or properties.exists():
        raise ValueError("Refusing to overwrite an existing signing configuration")
    key_path.write_bytes(key)
    key_path.chmod(0o600)
    values = {"storeFile": str(key_path), "storePassword": env["ANDROID_KEYSTORE_PASSWORD"],
              "keyAlias": env["ANDROID_KEY_ALIAS"], "keyPassword": env["ANDROID_KEY_PASSWORD"]}
    properties.write_text("".join(f"{name}={java_property(value)}\n" for name, value in values.items()), encoding="ascii")
    properties.chmod(0o600)
    output("track", track, env)
    output("version_name", version_name, env)
    output("version_floor", int(floor_text), env)
    print(f"Prepared signing for {PACKAGE}; closed track: {track}.")


class PlayClient:
    def __init__(self, session):
        self.session = session
        self.base = f"https://androidpublisher.googleapis.com/androidpublisher/v3/applications/{PACKAGE}/edits"

    def request(self, method, suffix="", body=None):
        response = self.session.request(method, self.base + suffix, json=body, timeout=30)
        if not response.ok:
            # Do not echo server response/credential details into build logs.
            raise RuntimeError(f"Google Play API {method} returned HTTP {response.status_code}; check app access, API enablement and test-release permissions")
        return response.json() if response.content else {}


def next_version(client, track, floor):
    track = closed_track(track)
    if not 0 <= floor < MAX_VERSION_CODE:
        raise ValueError("Version-code floor is outside Google Play limits")
    edit = client.request("POST", body={})
    edit_id = str(edit.get("id", ""))
    if not re.fullmatch(r"[A-Za-z0-9_-]+", edit_id):
        raise RuntimeError("Google Play did not return a valid edit ID")
    try:
        tracks = client.request("GET", f"/{edit_id}/tracks").get("tracks", [])
        if track not in {entry.get("track") for entry in tracks}:
            raise ValueError(f"Closed track {track!r} does not exist; create it in Play Console first")
        codes = [floor]
        for entry in tracks:
            for release in entry.get("releases", []):
                codes.extend(int(code) for code in release.get("versionCodes", []))
        for kind in ("bundles", "apks"):
            records = client.request("GET", f"/{edit_id}/{kind}").get(kind, [])
            codes.extend(int(item["versionCode"]) for item in records)
        if any(code < 0 or code > MAX_VERSION_CODE for code in codes):
            raise ValueError("Google Play returned an invalid version code")
        candidate = max(codes) + 1
        if candidate > MAX_VERSION_CODE:
            raise ValueError("Google Play's maximum version code has been reached")
        return candidate
    finally:
        # Inspection never commits a track change or leaves an edit open for a build.
        client.request("DELETE", f"/{edit_id}")


def allocate(env):
    # Imported only for the live API command; local tests need only Python stdlib.
    from google.oauth2 import service_account
    from google.auth.transport.requests import AuthorizedSession
    credentials = service_account.Credentials.from_service_account_info(
        json.loads(env["GOOGLE_PLAY_SERVICE_ACCOUNT_JSON"]),
        scopes=["https://www.googleapis.com/auth/androidpublisher"],
    )
    with AuthorizedSession(credentials) as session:
        code = next_version(PlayClient(session), env["GOOGLE_PLAY_CLOSED_TRACK"], int(env["VERSION_CODE_FLOOR"]))
    output("version_code", code, env)
    print(f"Next Android version code: {code}")


def cleanup(env, app=APP):
    for path in (Path(env["RUNNER_TEMP"]) / "pinpotha-upload.jks", app / "android/key.properties"):
        path.unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("prepare", "version", "cleanup"))
    args = parser.parse_args()
    try:
        {"prepare": prepare, "version": allocate, "cleanup": cleanup}[args.command](os.environ)
    except (ValueError, RuntimeError, OSError) as error:
        print(f"::error::{error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
