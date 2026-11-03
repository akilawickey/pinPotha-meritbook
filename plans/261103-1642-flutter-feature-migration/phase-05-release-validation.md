---
phase: 5
title: "Validate compatibility and prepare rollout"
status: in-progress
priority: P1
dependencies: [4]
---

# Phase 5: Validate compatibility and prepare rollout

## Overview
Prove feature and data compatibility, including an upgrade of an existing native installation, and prepare a recoverable release.

## Requirements
- Functional: Existing accounts/posts remain accessible across native, web and Flutter; Android upgrades install under the same identity; iOS device flows work.
- Non-functional: All release claims have executed evidence; no production mutations during automated validation and no publication as part of this plan.

## Architecture
Use emulator fixtures for database/rule tests, isolated test accounts for real Google auth/Storage, and signed internal testing for Android upgrades. The existing counter test references nonexistent `MyApp` (`test/widget_test.dart:16`); replace it before treating the suite as a gate. A release build is necessary but cannot prove OAuth signing, runtime permissions or upgrade/session behavior.

## Related Code Files
- Modify: `mobile-app/mobile-flutter-poc/test/widget_test.dart`, `README.md`, `pubspec.yaml`, `pubspec.lock`.
- Create: `mobile-app/mobile-flutter-poc/test/models/post_compatibility_test.dart`, `test/screens/migration_parity_test.dart`, `integration_test/migration_journeys_test.dart` (proposed new).
- Create: `mobile-app/mobile-flutter-poc/release-checklist.md` and isolated emulator test configuration/fixtures (proposed new; keep test configuration separate from production).
- Modify: Android signing/version configuration introduced in phase 01 and existing iOS build/version configuration as needed.
- Delete: Obsolete counter-test assertions when replaced; no application source deletion planned.

## Implementation Steps
1. Run meaningful model, widget, service and rules tests covering the report's validation matrix. Add integration-test dependencies/configuration when introducing the new integration suite.
2. From the Flutter directory run planned checks `flutter analyze`, `flutter test`, `flutter build appbundle --release`, and `flutter build ios --release --no-codesign`. Record actual toolchain and outcomes; follow with signed iOS archive/device validation. None of these commands were executed during this analysis.
3. Verify Google login, cancellation/relogin, camera/gallery denial and selection, create/edit/delete/share, calendar/date search and navigation on Android, iPhone and iPad. Verify live rules/configuration using intended test accounts, not assumed deployment state.
4. Install production native build, seed or select test-account history, and upgrade via signed internal Play testing without uninstalling. Compare post IDs/counts/notes/dates/URLs before and after, check auth continuity or successful reauthentication, and check native/web interoperability on isolated test data.
5. Verify package/signing, build number greater than the highest uploaded version, supported devices/OS, store/privacy/account requirements and release assets. Resolve whether web account-deletion functionality is needed for submission; do not silently expand native parity scope.
6. Prepare gradual rollout and monitoring steps, known-good source/config backup, stop criteria and higher-version recovery release procedure. Actual upload/publication is a subsequent release action; pause rollout on sign-in or data-integrity regressions.

## Success Criteria
- [ ] Analyzer, meaningful tests, platform builds and device journeys have recorded passing evidence with no placeholder counter suite.
- [ ] Internal-track upgrade over the production native app succeeds and cloud data matches the before/after reference.
- [ ] Play-installed Google sign-in and iOS physical-device behavior pass; no previous-user state is exposed after switching accounts.
- [ ] Release checklist resolves production identity, live configuration, OS compatibility, account/store scope and recovery procedure.

## Risk Assessment
Missing signing access or production baseline blocks release validation, even when implementation builds locally. Old clients may remain active during staged rollout, so preserve schema throughout. Recover with a higher-version release; a source rollback cannot undo erroneous user-data deletion.
