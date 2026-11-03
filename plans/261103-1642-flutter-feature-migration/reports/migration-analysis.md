# Migration analysis

## Evidence and limits

Inspected the local `master` checkout at commit `e00ae59f7bd76bde6d773a4a89b7f370e2a83539` on 3 November 2026, Asia/Colombo. GitHub directory retrieval failed, so remote master equality is unverified. No applicable `AGENTS.md` or existing related plan was found. Existing unrelated modifications, including the native release AAB and web sign-in file, were left untouched. A checked-in AAB, version configuration, and source history do not establish what is installed from Play.

Paths below are repository-relative. `N` abbreviates `mobile-app/pinPotha realtime db/app/src/main/java/asak/pro/pinPotha`; `F` abbreviates `mobile-app/mobile-flutter-poc/lib`. Line references describe the inspected checkout. Analysis is static: no app suite, build, sign-in, production database request, console inspection, or device upgrade was executed.

## Feature comparison

| Feature | Native source evidence | Flutter evidence and migration work |
|---|---|---|
| Google sign-in/session restore | `N/activities/SignInActivity.java:47` | Present in `F/providers/auth_provider.dart:24`; simplify token retries/debugging and repair root auth navigation. Verify real Android/iOS OAuth configuration. |
| Calendar Home | `N/activities/DashboardActivity.java:105` | Missing; Flutter Home is an all-post grid (`F/screens/dashboard_screen.dart:128`). Add month/year navigation and selected-day state. |
| Days with posts | `N/activities/DashboardActivity.java:243` | Missing; reproduce one/multiple-post indicators using shared post data. |
| Selected-day summary and empty-day add | `N/activities/DashboardActivity.java:262` | A date-list screen exists (`F/screens/post_list_screen.dart:12`) but has no caller in `lib/`; connect it to calendar selection and preserve the selected date. Native uses a summary dialog, so a full date-list screen is a proposed presentation choice. |
| Add note, photo, or both | `N/activities/PostListActivity.java:167`; `N/models/Utils.java:66` | Already present (`F/screens/add_post_screen.dart:61`, `:107`). Reuse form; add save failure recovery and ensure auth/email guards before upload. |
| Choose post date | `N/activities/PostListActivity.java:141` | Present (`F/screens/add_post_screen.dart:93`), but Flutter limits dates to 2000..today while native picker sets no such bounds. Resolve future/older-date handling; do not crash when opening a legacy date outside bounds. |
| All-post grid | `N/activities/GoodThingsActivity.java:48` | Present as Flutter dashboard; repurpose as View tab rather than rewrite. |
| Search note and date | `N/activities/GoodThingsActivity.java:148` | Flutter searches notes only (`F/screens/dashboard_screen.dart:104`); include `dd-MM-yyyy` date matching and trimmed query. |
| Details | `N/activities/DetailsActivity.java:35` | Present (`F/screens/post_details_screen.dart:34`), but reads all posts and finds by ID. Pass original date key and read exact record or shared in-memory state. |
| Edit note | `N/activities/DetailsActivity.java:119` | Flutter edits date/photo/note (`F/screens/post_details_screen.dart:138`), a broader scope. For parity, patch only `note`, preserving timestamp and photo. |
| Delete with confirmation and photo cleanup | `N/activities/DetailsActivity.java:160` | Present (`F/screens/post_details_screen.dart:83`); retain original record path and make cleanup failure visible/retryable. |
| Share | `N/activities/DetailsActivity.java:215` | Native shares note as subject and photo URL as text; Flutter shares note/fallback only (`F/screens/post_details_screen.dart:154`). Include available note and URL in shared text, with iPad presentation configuration verified against the selected plugin. Sharing a downloaded image file is not existing parity. |
| Four-tab navigation | `N/activities/DashboardActivity.java:174`; native `res/menu/bottom_nav_menu.xml:1` | Flutter Home/Add/Menu (`F/widgets/bottom_navigation.dart:37`); add Home/Add/View/Settings, preserve state, avoid repeated route pushes. Menu currently attempts to open a drawer even on screens with none. |
| Profile/logout | `N/activities/DashboardActivity.java:337`, `:348`, `:380` | Drawer shows profile and logout (`F/widgets/mobile_drawer.dart:19`, `:108`). Keep access and confirmation, repair login after logout and account isolation. |
| Settings/version | `N/activities/SettingsActivity.java:20` | Missing settings screen; About hardcodes `1.0.0` (`F/widgets/mobile_drawer.dart:180`). Add actual installed version/build using an appropriate package-info dependency. Native Settings currently displays version only. |
| Pagination/refresh | Native loads whole user tree (`N/activities/GoodThingsActivity.java:117`) | Flutter extras already exist; display pagination does not reduce database reads. Repair page-size selection, page bounds, and duplicate refresh subscriptions. |
| Persistent offline use | Native add checks connectivity (`N/activities/PostListActivity.java:167`) | Flutter README claims offline support; no persistence setup is present in `lib/`. Treat disk persistence and queued save UX as unimplemented/unverified rather than a completed feature. |

## Backend compatibility

Both configurations refer to project `pinpotha-1295`, Realtime Database `https://pinpotha-1295.firebaseio.com`, and bucket `pinpotha-1295.appspot.com`: native `app/google-services.json:4`; Flutter `F/firebase_options.dart:33`.

```text
posts/{email.replace('.', ',')}/{dd-MM-yyyy}/{postId}
  postId: string
  note: string (optional)
  photoUrl: string (optional)
  timeStamp:
    server_time: epoch milliseconds, historically string or number

photos/{objectId}
```

Native `N/models/Utils.java:98`, `:111`, `:121`, `:215`, `:256` and model `N/models/Post.java:10` establish the existing write contract. Flutter `F/utils/post_utils.dart:7`, `:15`, `:30`, `F/models/post.dart:18`, and `F/models/timestamp_data.dart:7` mostly match it. No bulk data migration is indicated by this evidence. Users may need to sign in again during an engine replacement; session continuity must be measured rather than promised.

Keep email-derived paths for this migration. The checked-in rules authorize those paths and require matching `postId` plus `timeStamp/server_time` (`database.rules.json:5`, `:13`). UID paths would require a separate compatibility migration across native, Flutter, web, rules, and deletion functions. The web reads this same tree (`web/src/utils/postUtils.js:145`); account deletion traverses it and deletes photos (`functions/index.js:55`, `:129`). Do not change shared field semantics casually.

No Storage rules file was found, and `firebase.json` defines database rules but no Storage rules deployment. Live rules, bucket ownership, auth provider settings, App Check state, and indexes have not been inspected. Verify these before enabling the new client; repository configuration is not deployed-state evidence.

## Required integrity and lifecycle fixes

1. **Original post location is lost.** `F/services/post_service.dart:20` discards the enclosing date key. Update/delete derive a path from a `DateTime` (`:105`, `:131`), and details selects the first matching ID (`F/screens/post_details_screen.dart:49`). Timestamp-to-local-date conversion can differ from the original path when timezones change; malformed timestamps currently fall back to now. Add a required in-memory source date key and navigate by `(dateKey, postId)`. Read timestamps tolerantly, use the parsed source date key as a clearly marked display fallback, and never use fallback time to locate a write. Calendar dots and selected-day lists must use the same shared display-date filter; do not show timestamp-based dots but query a different source date bucket when opening a day. Preserve legacy string values on note-only edits.
2. **Date edit duplicates a post.** The editor passes only the selected new date (`F/screens/add_post_screen.dart:135`); service `set()` creates/overwrites that location without removing the old one (`F/services/post_service.dart:115`). Native parity only requires note editing. Lock date/photo changes for first parity, or move old/new paths in one multi-location database update with unchanged post ID. On denied write neither location should change. Retry with the same identity; do not generate a second post. Test with current rules. Full simultaneous-edit conflict resolution is not present in native and remains separate scope; document last-writer-wins behavior.
3. **Auth gate can disappear.** `SplashScreen` chooses authenticated UI (`F/screens/splash_screen.dart:14`), but Home clears all routes (`F/widgets/bottom_navigation.dart:44`) and logout replaces the stack with `SignInScreen` (`F/widgets/mobile_drawer.dart:138`). That sign-in screen expects SplashScreen to navigate after auth (`F/screens/sign_in_screen.dart:47`). A root gate must remain mounted regardless of tabs; clear old user state and subscriptions on sign-out/account change.
4. **Repeated listeners and incomplete async errors.** Dashboard calls `.listen()` per load/refresh/return without storing/cancelling subscriptions (`F/screens/dashboard_screen.dart:57`, `:98`, `:157`); details does the same (`F/screens/post_details_screen.dart:46`, `:151`). Auth listener is not retained for disposal (`F/providers/auth_provider.dart:44`). Share one subscription per active user, dispose properly, and await/catch token futures. Loading, empty, denied, malformed, and not-found must be distinct states. Returning a list from `Stream.handleError` does not emit a replacement event (`F/services/post_service.dart:10`, `:47`); change the error contract explicitly.
5. **Photo operations span two services.** Upload precedes database save (`F/screens/add_post_screen.dart:126`), so failure can orphan the new object. Photo removal skips old-object cleanup because service only deletes when the new URL is non-null (`F/services/post_service.dart:118`). Cleanup currently swallows failures (`F/utils/post_utils.dart:41`). Preserve old object until the post commit, compensate new uploads after a definitely rejected database save (reconcile unknown commit outcomes before cleanup), use SDK URL-to-reference support for legacy URLs, and expose cleanup retry separately from post-save success. Database and Storage cannot be treated as one transaction. If users retain broader editing, include replace/remove tests.
6. **Pagination controls are inconsistent.** Page size is final `12` and the selector never changes it (`F/screens/dashboard_screen.dart:30`, `:229`). Removing posts on a later page can make `sublist` invalid (`:114`). Use mutable page size, reset/clamp pages when data/search changes, dispose refresh controller, and finish refresh on an actual result/error. Keep whole-user read for initial compatibility, then profile rather than introducing a new schema prematurely.
7. **Prototype diagnostics remain in sign-in.** Auth calls token diagnostics twice and repeatedly forces refresh (`F/providers/auth_provider.dart:105`); helper logs email/UID/base64 claims (`F/utils/token_debug.dart:14`). Its “database access test” only refreshes a token (`:56`), so it proves no database authorization. Remove from normal auth, sanitize logging, use UID rather than email for analytics identity, and verify rules with actual emulator/staging operations.

## Platform and release work

- Flutter contains `ios/` but no `android/`; `F/firebase_options.dart:14` explicitly throws on Android. Generate Android host files within this Flutter project, select compatible Gradle/JDK/SDK/plugin versions, register/use the verified existing Android Firebase app, and configure permissions, icons, launcher name, Google services, and release signing.
- Native Gradle declares application ID `asak.pro.pinPotha`, version `5.6`, code `17`, min SDK `16`, and target SDK `35` (`mobile-app/pinPotha realtime db/app/build.gradle:4`). Flutter is `1.0.0+1` (`mobile-app/mobile-flutter-poc/pubspec.yaml:4`). Verify Play Console values, then select a release build number above every uploaded version. Do not assume code 18 is sufficient.
- There are two Android package entries in native Google services JSON (`:13`, `:65`), so use the actual store app, not an inferred organization name. Same application ID and compatible app-signing identity are necessary for existing installation updates; an upload key is not the Play app-signing key. [Android application identity](https://developer.android.com/build/configure-app-module), [app signing](https://developer.android.com/studio/publish/app-signing), [versioning](https://developer.android.com/studio/publish/versioning).
- Configure OAuth fingerprints for relevant debug and release/Play app-signing certificates, then test Google login in a Play-installed internal-track build. [Firebase Flutter Google authentication](https://firebase.google.com/docs/auth/flutter/federated-auth).
- iOS bundle is `com.leafylanka.pinpotha`; its plist permissions and Google URL scheme exist (`mobile-app/mobile-flutter-poc/ios/Runner/Info.plist:48`), and Xcode references `GoogleService-Info.plist` (`ios/Runner.xcodeproj/project.pbxproj:18`), but the actual file is absent locally. Restore correct environment configuration, verify client ID/scheme, signing team/capabilities, icons, deployment target and physical device behavior. Dart Firebase options do not prove the native Google Sign-In setup is complete.
- Current dependencies are constrained in pubspec and lockfiles; a compatible SDK/plugin matrix must be established before choosing upgrades. Do not blindly update all packages. Native min SDK 16 is not a promise the Flutter engine and plugins can preserve that OS floor.
- Offline disk persistence requires explicit configuration before database use and testing. It does not provide durable Storage uploads automatically. Default to online saves with retained in-session draft and an explicit pending/error state. If selected, add cached read persistence with account isolation and clear UX for server acknowledgement. [Firebase offline capabilities](https://firebase.google.com/docs/database/flutter/offline-capabilities).
- Atomic multi-path updates can support a date move without splitting database records; Storage work remains separate. [Firebase read/write semantics](https://firebase.google.com/docs/database/flutter/read-and-write).
- Account deletion is a web feature and callable backend already exists, but neither compared mobile client implements that flow. Decide first-release scope and verify applicable store rules separately before submission; do not label this a missing native feature.

## Validation and rollout design

The only Flutter test is an untouched counter template invoking nonexistent `MyApp` (`mobile-app/mobile-flutter-poc/test/widget_test.dart:16`); app class is `PinPothaApp` (`F/main.dart:40`). This is a source-observed test blocker, not a test-run result. Replace it with meaningful journeys and model/service tests; introduce Firebase dependency seams as needed rather than using production data in tests.

| Area | Required observable cases |
|---|---|
| Legacy compatibility | Numeric/string timestamp, note-only/photo-only/both, missing optional fields, malformed timestamp, original path/date differing from local timestamp date. No rewritten history on load. |
| Identity and permissions | User A allowed only under A; user B denied on A; unauthenticated access denied; matching postId required; legitimate legacy-compatible save accepted. |
| Creation/recovery | Empty form blocked; camera/gallery cancel/denial; upload failure; upload success/database failure; repeated tap/retry uses one post; draft retained on failed save. |
| Edit/delete | Note edit preserves date/photo/timestamp; timezone switch still targets original path; denied writes keep data; delete confirmation cancel; database success/storage failure reported as cleanup issue. If broader edit enabled: atomic move, replace, remove, and failed move. |
| Authentication | Cold session restore, cancelled Google login, network failure, logout/relogin, account A→B, token expiry, and back navigation after logout from every tab. No stale listeners or previous-user posts. |
| Feature parity | Month/year navigation, leap day/year boundary, one/multiple post dots, empty date, add on selected day and return, search date/note/Sinhala, share note and URL, settings actual version, tab/back-state preservation. |
| List reliability | Change page size; delete last post on last page; external realtime update; repeated refresh/navigation without accumulating subscriptions; denied read is not “no posts.” |
| Platforms and upgrade | Android camera/gallery/share/login through installed signed bundle; iPhone and iPad behavior; upgrade native production installation to Flutter through internal testing without uninstall; old native/web and Flutter see compatible data. |

Use isolated emulator fixtures for database/rules checks, staging/test accounts for real auth/Storage and physical device tests, then a signed Play internal-track update. Record actual SDK versions, supported OS range, fixture counts/IDs, failures and evidence. Keep production untouched during implementation validation. If available, run `flutter analyze` and `flutter test` after implementation; add integration test tooling and commands when those tests exist. Build `flutter build appbundle --release` and `flutter build ios --release --no-codesign`, followed by signed archive/device checks; a compile alone is not release validation.

Before rollout, inventory live version/signing, test data access after upgrade, and verify store/privacy/account requirements. Roll out gradually under an explicit release action. On regression pause rollout; a recovery release must use a higher version code, potentially rebuilding the native source against the unchanged backend. Preserve known-good source/configuration and capture a backend backup before any future schema-changing work; this plan itself needs no data rewrite. Code rollback cannot reverse a mistaken deletion, so validate write paths before any production adoption.

## Review outcome

Performed separate contract, failure-path, security, and scope passes in the same agent. Corrected the initial assumption that existing Flutter CRUD means parity: note/date edit semantics, photo-link sharing, date search, auth-root ownership, Android setup, and version settings require work. Kept UID migration, server pagination redesign, Firestore, durable offline photos, and automatic web-feature expansion outside this migration. Production identity/configuration and product decisions remain open; implementation phases are pending. Blueprint validation is recorded after writing the plan; no application test results are claimed.
