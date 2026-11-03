# Implementation verification

Implemented on 3 November 2026 in `mobile-app/mobile-flutter-poc`. No native/web
application source, database rules, production data, live configuration or deployment
was changed. Existing unrelated workspace changes were preserved.

## Delivered

- Android host with source package `asak.pro.pinPotha`, existing Firebase client
  configuration, reused Android launcher artwork and guarded release signing.
- Preserved iOS host metadata alongside the new Android metadata. Added a reproducible
  helper to restore the ignored native Firebase plist from checked-in iOS options;
  this local reconstruction still needs comparison with Firebase Console.
- Root authentication gate above a nested navigator, system-back handling, UID-based
  analytics identity and disposal of auth/post listeners. Token-claim diagnostics removed.
- User-scoped post state shared across calendar, date list, View and details. Original
  date bucket retained in memory and used for note updates/deletion. Existing persisted
  field names, email paths, photo paths and legacy string timestamps retained.
- Calendar month/year navigation, one/multiple-post indicators, selected-day browsing
  and creation, four tabs, profile/logout and installed version/build in Settings.
- Note/date/Sinhala search, corrected page size and deletion page bounds, refresh with
  owned subscription, photo-link sharing and iPad share-origin configuration.
- Note-only editing for native parity. Date/photo edits disabled rather than enabling
  an unsafe move. Photo-only and note-only creation remain supported.
- Stable create identity and frozen payload on retry, duplicate-tap protection,
  pending-save indication, retained in-session drafts, discard confirmation and
  protection against logout during pending operations. Completed uploads with a failed
  download-URL lookup retain their object location for cleanup.
- Record deletion separated from photo cleanup; photos referenced by another loaded post are preserved. Explicit in-session cleanup retry in
  Settings. Failed draft uploads are cleaned when discarded; a successful save never
  schedules deletion of its own photo.

## Executed checks

| Check | Result |
|---|---|
| `flutter pub get` | Passed with lockfile updated for package-info and share plugin changes. |
| `flutter analyze` | Passed: no issues found after final source changes. |
| `flutter test --reporter expanded` | Passed: 23 model, repository, recovery and widget tests, including valid historical dates before 1970 and shared-photo protection for legacy duplicate records. |
| Isolated Auth/Database emulator tests | Passed: 7 compatibility/authorization checks against the actual repository rules, using `demo-pinpotha-default-rtdb` only. |
| `flutter build ios --release --no-codesign` | Passed; unsigned `build/ios/iphoneos/Runner.app`. Final source changes are included (last build completed successfully in 19.9 seconds). |
| Android debug compilation | Passed: `build/app/outputs/flutter-apk/app-debug.apk` (about 148 MiB). A Gradle Properties import error and generated Kotlin cache race were corrected; final build used in-process Kotlin compilation and limited workers. |
| Android unsigned release bundle and signing safeguard | Unsigned release bundle compiled successfully (46.4 MB). Default release dry-run correctly rejected missing `android/key.properties`; this expected safeguard failure is not a compilation failure. Final debug/release rebuilds passed after removing an unnecessary inherited microphone permission; merged release manifest and unsigned bundle contents were checked. |
| `git diff --check` | Passed. |
| Plan blueprint validator | Passed for all five phase files; final consistency sweep recorded after build verification. |

The initial emulator attempt used a namespace different from the CLI-loaded rules;
that attempt failed and was corrected. The final seven checks pass against the rules
loaded by the CLI. No conclusion about deployed production rules is implied.

## Toolchain and operational limits

Flutter 3.35.6, Dart 3.9.2, generated Android Gradle 8.12 / AGP 8.9.1 / Kotlin 2.1.0,
JDK 17; Xcode 26.4.1, iOS deployment target 13. APK metadata confirms package `asak.pro.pinPotha`, compile/target API 36, and minimum API 24. Android minimum API 24 is required by
the resolved image-picker dependency and is a support reduction from native minSdk 16.
No attempt was made to promise support for devices excluded by those dependencies.

Live store package/version/certificate and published-source equality remain unverified.
The website's download link also uses `asak.pro.pinPotha`, but the Play page could not
be retrieved. Source native version is `5.6`/`17`; Flutter pubspec intentionally remains
`1.0.0+1` pending live version verification. A real release must supply a build number
above the highest uploaded version and the existing authorized signing arrangement.
Normal release builds fail without local signing configuration. Explicit unsigned
compilation uses `ORG_GRADLE_PROJECT_allowUnsignedRelease=true` and is not a production
artifact.

Physical Google login, camera/gallery permission behavior, iPad sharing, signed archive,
Play internal-track installation/upgrade, live rules/Storage/App Check configuration,
and submission/account-deletion requirements remain pending. These are tracked in
`mobile-app/mobile-flutter-poc/release-checklist.md` and phases 01/05.

Drafts, pending client writes and cleanup retry state are in-session only. Closing the
app or signing out can lose unsaved drafts or retry metadata. Durable offline photos
and server-managed cleanup are separate scope. Full-account reads and existing
last-writer-wins semantics remain; pagination is display-only. No schema/data migration,
backend deployment, store upload or production release was performed.
