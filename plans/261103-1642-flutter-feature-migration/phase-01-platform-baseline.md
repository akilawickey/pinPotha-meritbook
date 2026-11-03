---
phase: 1
title: "Confirm baseline and platform setup"
status: in-progress
priority: P1
dependencies: []
---

# Phase 1: Confirm baseline and platform setup

## Overview
Establish the actual production reference and make the existing Flutter project buildable for Android and iOS.

## Requirements
- Functional: Android must be capable of updating the existing published app; iOS configuration must remain functional.
- Non-functional: Record reproducible toolchain versions, signing arrangement and supported OS floors without committing signing secrets.

## Architecture
Use the existing Flutter app as the shared client with separate Android/iOS host configurations. Native identity is provisionally `asak.pro.pinPotha`, based on native `app/build.gradle:7`; verify against Play Console first. Flutter Android options are absent (`lib/firebase_options.dart:14`), and the iOS native Google services plist is referenced but missing locally. See [platform evidence](reports/migration-analysis.md).

## Related Code Files
- Create: `mobile-app/mobile-flutter-poc/android/` host files and Firebase configuration (new).
- Create: `mobile-app/mobile-flutter-poc/ios/Runner/GoogleService-Info.plist` environment configuration (absent locally; follow repository ignore policy).
- Modify: `mobile-app/mobile-flutter-poc/lib/firebase_options.dart`, `pubspec.yaml`, `pubspec.lock`, `.metadata`.
- Modify: `mobile-app/mobile-flutter-poc/ios/Podfile`, `ios/Podfile.lock`, `ios/Runner/Info.plist`, `ios/Runner.xcodeproj/project.pbxproj`, `README.md` as required by the tested matrix.
- Delete: None planned.

## Implementation Steps
1. Compare the actual installed production app to the feature matrix; record package, version, signing fingerprints and release source. Keep release identity unverified until evidence is available.
2. Select a tested Flutter/Dart/JDK/Gradle/plugin matrix, record OS exclusions relative to native minSdk 16, and review current submission requirements without assuming historical target SDK 35 is sufficient.
3. Generate Android support in the existing Flutter folder, set the verified application ID and connect it to the existing Firebase project/app. Configure Google OAuth with relevant debug and Play signing fingerprints.
4. Restore iOS environment configuration and verify bundle/client/scheme consistency, signing setup, permissions, icons and deployment target.
5. Resolve dependency conflicts with targeted changes; record build prerequisites and correct README paths referring to the old `mobile/` directory.

## Success Criteria
- [ ] Production baseline and package/signing facts are recorded or explicitly blocked before release work.
- [ ] Android Firebase startup no longer throws unsupported-platform; both platform configurations build with the documented toolchain.
- [ ] Google sign-in succeeds on Android and iOS test devices using the intended Firebase project.

## Risk Assessment
Choosing the wrong Android package creates a separate app. Missing signing authority blocks upgrade validation. Do not guess the package from Firebase's second Android client, copy signing secrets into source, or treat debug login as proof that Play login will work.
