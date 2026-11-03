# Automatic Android closed testing

Workflow: [`android-closed-testing.yml`](android-closed-testing.yml).

Every push to **master** runs the Flutter analyzer/tests, builds a signed release APK
and AAB, saves both as GitHub Actions artifacts for 30 days, and uploads the **AAB**
to Google Play's **alpha closed-testing track** for `asak.pro.pinPotha`.
Relevant pull requests run checks without signing or publishing.
A manual **Run workflow** trigger is also available; select `master` to publish.
Google Play processes/reviews releases as applicable, and only enrolled testers can
receive the update. This workflow does not email APKs or change tester enrollment.

The Flutter migration required by this workflow must be merged along with the workflow.
The existing Firebase/web deployment workflow is unchanged. Merging to master also
triggers that existing Firebase workflow; verify its intended web source separately.

## One-time Play Console setup

1. Confirm the existing app is `asak.pro.pinPotha` and that its closed testing track ID
   is `alpha` (the configured default). Complete any required app setup and initial
   manual upload; the app and track must exist before API publishing.
2. Create/use a Google Cloud service account and enable the **Google Play Android
   Developer API** in its Cloud project.
3. In Play Console **Users and permissions**, invite the service account's email,
   restrict it to this app, and grant access to view app information and **release
   apps to testing tracks**. Production release permission is not needed. Firebase
   permissions alone do not grant Play publishing access.
4. Export that account's JSON key to a secure local file for the secret below.
5. Use the app's existing authorized **upload key** (or existing app signing key if
   not using Play App Signing). Do not generate a replacement key for this pipeline.
   Configure the Play app-signing certificate's SHA fingerprints in Firebase so that
   Google sign-in works in Play-installed builds.
6. Add the intended testers/group and share Play Console's closed-test opt-in link.

References: [Google Play API access](https://developers.google.com/android-publisher/getting_started),
[Play testing tracks](https://developers.google.com/android-publisher/tracks).

## GitHub secrets

Add these five secrets in repository **Settings → Secrets and variables → Actions**,
or in the `play-closed-testing` environment. Supply values directly to GitHub; do not
commit credentials or paste them into workflow YAML.

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Base64 of the existing upload keystore file. |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password. |
| `ANDROID_KEY_ALIAS` | Existing signing/upload key alias. |
| `ANDROID_KEY_PASSWORD` | Key password (may equal the keystore password). |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Entire Google Play service-account JSON key. |

On macOS, copy the encoded keystore directly to the clipboard:

```sh
base64 -i /absolute/path/to/existing-upload-key.jks | tr -d '\n' | pbcopy
```

If GitHub CLI is installed and authenticated, secrets can be set without printing
credential contents. Example for the service account:

```sh
gh secret set GOOGLE_PLAY_SERVICE_ACCOUNT_JSON \
  --repo akilawickey/pinPotha-meritbook < /secure/path/play-service-account.json
```

Enter passwords/alias through the GitHub secrets interface or `gh secret set`'s
interactive prompt. GitHub's [secret setup documentation](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets)
explains repository and environment secrets.

The job names its deployment environment `play-closed-testing`. Environment approval
or branch-protection rules, if configured in GitHub, still apply. Do not configure a
required reviewer if you want fully automatic uploads after each master push.

## Optional GitHub variables

| Variable | Default and purpose |
|---|---|
| `GOOGLE_PLAY_CLOSED_TRACK` | `alpha`, as requested. Override only for another existing custom closed-testing track. Production, open (`beta`), internal and multi-track values are rejected. |
| `ANDROID_VERSION_NAME` | Version before `+` in Flutter `pubspec.yaml`. Set the desired display version here, or update pubspec. The migration pubspec is currently `1.0.0+1`; choose the intended release name before enabling uploads. |
| `ANDROID_VERSION_CODE_FLOOR` | Build number in pubspec. Optional recovery floor: allocation uses `max(floor, existing Play version codes) + 1`. |

Version allocation checks releases on **all tracks**, uploaded bundles and uploaded
APKs in a temporary Play edit, then deletes the edit without committing it. A rerun
queries Play again, so a previous successful upload gets a new version code. If
another publisher reserves/uses a code outside this pipeline, rerun after its edit
is committed or raise the floor; uploads from separate tools are not serialized by
GitHub's concurrency group.

The whole pipeline is serialized with `queue: max` and no cancellation. GitHub
queues up to 100 pending runs rather than replacing the pending push; excess runs
are subject to GitHub's queue limit. [GitHub concurrency documentation](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-workflow-concurrency).

## Running and downloading

1. Configure the five secrets and any desired variables.
2. Merge the Flutter migration and pipeline into `master`.
3. Open **Actions → Android closed testing** to follow the triggered run, or use
   **Run workflow → master**.
4. Download `pinpotha-android-<versionCode>` from the run's **Artifacts** section.
   It contains the signed APK and AAB even if a subsequent Play upload fails.
5. Check **Play Console → Testing → Closed testing → alpha** for the release and
   review status. Testers use their existing opt-in link to obtain the Play update.

An APK signed with the upload key may not update a Play-installed app when Play App
Signing uses a different app-signing key. Use the Play closed-testing update to test
upgrades over production. Do not uninstall a real user's app just to install an artifact.

## Troubleshooting

- **Missing secrets:** the job names missing secrets and stops before building or
  uploading. The independent checks job can still pass without signing credentials.
- **403 / app not found:** enable the Publisher API, check the service-account email's
  Play Console app access, and grant test-track release/view permissions.
- **Track missing:** create/verify the alpha closed track in Play Console. Never
  change the variable to production as a workaround.
- **Wrong signing key:** use the app's already authorized upload/signing key; do not
  substitute a debug keystore.
- **Version already used / reserved code:** rerun after other publishers finish,
  or set `ANDROID_VERSION_CODE_FLOOR` above the reserved range.
- **Draft app / review required:** complete the initial app/track setup and outstanding
  Play Console declarations. `status: completed` requests availability to testers;
  Play review and eligibility requirements can delay availability.
- **Google login fails only in Play:** register the **Play app-signing certificate**
  fingerprints in Firebase, not only the local upload/debug certificate.

## Validation and activation status

The helper tests run locally and in the checks job:

```sh
cd mobile-app/mobile-flutter-poc
python3 -m unittest discover -s tool/tests -v
```

They cover signing-file permissions/escaping, secret validation, closed-track guards,
version allocation across tracks and artifacts, reruns, API failure cleanup and the
Google Play version-code limit. Flutter's existing analyzer and 23 tests are part
of the workflow as well. A local test is not a live Play upload: credentials and the
first successful GitHub run must be verified after setup.

Local workflow validation uses actionlint v1.7.12. That release does not yet recognize
GitHub's documented `concurrency.queue` field; all other syntax/expressions pass
when only that field is omitted from a temporary validation copy. The committed
workflow retains `queue: max`, checked against the official concurrency documentation
above, so back-to-back master pushes are queued rather than silently replaced.
