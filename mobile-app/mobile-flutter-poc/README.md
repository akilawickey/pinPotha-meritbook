# PinPotha for Android and iOS

Flutter migration of the native PinPotha Realtime Database app. Uses the existing
Firebase project and data; no bulk copy or schema migration is required.

## Features

- Google sign-in, profile, logout and account isolation.
- Home calendar with month/year navigation and indicators for one/multiple posts.
- Selected-day browsing and creation; note, camera photo, gallery photo, or both.
- View grid with note/date search, working page-size selection and display pagination.
- Details, note-only editing, confirmed deletion and note/photo-link sharing.
- Home / Add / View / Settings tabs; settings reads the installed version/build.
- One shared live post subscription per signed-in account.

Editing deliberately changes only the note, matching the native Android app. Date
and photo editing are disabled. Updates and deletion address the original saved
date bucket, independent of timestamp display or device timezone. Historical numeric
and string timestamps are supported. Invalid timestamps use the saved bucket date
and are visibly marked; malformed bucket structure produces an explicit read error.

## Toolchain and platforms

Validated SDK: Flutter 3.35.6 / Dart 3.9.2. Android host: Gradle 8.12, AGP 8.9.1,
Kotlin 2.1.0, JDK 17; compile/target SDK come from this Flutter SDK. Android minimum
API is **24** (Android 7), required by the resolved image picker. This excludes older
devices supported by the Java application's minSdk 16. iOS deployment target is 13.
Check device distribution and current store requirements before release.

Dependencies are locked; avoid upgrading the whole Firebase/plugin stack during
migration. `share_plus` was updated to 10.1.4 and `package_info_plus` 8.3.1 added.

## Setup

From `mobile-app/mobile-flutter-poc`:

```sh
flutter pub get
python3 tool/restore_ios_firebase_config.py
flutter run
```

The iOS helper restores the ignored `ios/Runner/GoogleService-Info.plist` from
checked-in Firebase options and validates the Google URL scheme. It preserves an
existing file. Compare it with the actual download from Firebase Console before
release; reconstructing a plist does not verify live OAuth configuration. Open
`ios/Runner.xcworkspace` for signing and device builds.

Android uses `asak.pro.pinPotha` from the existing native application's source and
`android/app/google-services.json` from that app. The iOS bundle is
`com.leafylanka.pinpotha`. Confirm both against the actual store/Firebase apps.
Register debug and Play app-signing certificate fingerprints for Google login;
a working debug login alone does not validate a Play-installed build.

## Data and offline behavior

```text
posts/{email.replace('.', ',')}/{dd-MM-yyyy}/{postId}
  postId, note?, photoUrl?, timeStamp/server_time
photos/{objectId}
```

Existing rules and web/native consumers are retained. Posts keep the source date
key in memory, without introducing a new persisted field. Calendar dots and day
lists use the same display-date grouping. Pagination limits displayed cards, not
database downloads; the full account tree is subscribed once.

New saves require a database connection. A dropped connection during an existing
write may leave it pending: keep the app/screen open until it finishes. Repeated
taps cannot duplicate a save. Rejected saves retain a frozen draft, uploaded photo,
and post ID; Retry sends the same payload. Discard cleans up an unreferenced upload.
Pending operations prevent leaving the form or signing out. Tabs preserve the Add
draft; leaving a routed form confirms discard. Drafts and cleanup retries are
**in-session only** and are lost on app termination. Disk persistence, durable offline
photo uploads, date/photo editing, and automatic background cleanup are not enabled.

Deleting the record and cleaning up its photo are separate operations. A successful
record deletion is not reported as failed if photo removal fails; Settings exposes
photo cleanup retry. Failed cleanup can remain after closing/signing out; review a
server-managed cleanup queue separately if durable guarantees are required.

## Checks

From the Flutter folder:

```sh
flutter analyze
flutter test --reporter expanded
flutter build apk --debug
flutter build ios --release --no-codesign
```

Tests cover legacy payloads, source-path writes, retry identity, upload/save failure,
cleanup recovery, auth/navigation/account switching, date search, selected-day
creation, retained drafts and pagination boundaries. Widget tests inject a fake
repository and authentication stream; they do not use production Firebase.

From the **repository root**, run the actual database rules in isolated emulators:

```sh
firebase emulators:exec --only auth,database --project demo-pinpotha \
  --config firebase.migration-test.json \
  'node mobile-app/mobile-flutter-poc/test/firebase/rules_test.mjs'
```

Requires Firebase CLI, Node with `fetch`, and Java. The test script hardcodes localhost
and the demo namespace, with no production fallback. It checks own-user access,
cross-user/anonymous denial, post ID validation, note preservation and deletion.
It does not test deployed rules, Storage rules, Google OAuth, camera hardware or
store upgrade compatibility. See [release-checklist.md](release-checklist.md).

## Release signing

`pubspec.yaml` remains `1.0.0+1` until the live version is verified. For an update,
supply a build name and build number greater than the highest uploaded store build;
native source code 17 is only a historical reference.

Create ignored `android/key.properties` with the existing authorized upload/signing
credentials, using an absolute `storeFile` path:

```properties
storeFile=/absolute/path/to/existing-upload-key.jks
storePassword=YOUR_LOCAL_SECRET
keyAlias=YOUR_EXISTING_ALIAS
keyPassword=YOUR_LOCAL_SECRET
```

The Android manifest excludes the unused camera dependency’s microphone permission.
Normal Android release builds fail if signing configuration is absent. For an
explicit **unsigned compilation check only**, use:

```sh
ORG_GRADLE_PROJECT_allowUnsignedRelease=true flutter build appbundle --release
```

This does not produce a verified, signed production update. Do not distribute it.
Use the real signing configuration and verified version overrides for release.

## Automatic closed-testing delivery

The [Android closed-testing workflow](../../.github/workflows/android-closed-testing.yml)
checks the Flutter app and publishes signed AABs to Play's `alpha` track on every
`master` push; the signed APK is also saved as an Actions artifact. Follow the
[one-time setup](../../.github/workflows/ANDROID_CLOSED_TESTING.md) for signing and Play
service-account secrets. No production track is targeted.
