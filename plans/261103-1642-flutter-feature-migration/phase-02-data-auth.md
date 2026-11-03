---
phase: 2
title: "Preserve data and authentication contracts"
status: completed
priority: P1
dependencies: [1]
---

# Phase 2: Preserve data and authentication contracts

## Overview
Establish safe record addressing and authenticated state ownership before expanding screens.

## Requirements
- Functional: Existing users read/write their existing email/date/post paths with legacy timestamps; logout/relogin/account switch remain usable.
- Non-functional: One owned user-scoped post subscription; no production token-claim logging or previous-user state leakage.

## Architecture
Keep a root auth gate mounted above the navigation shell. Bind post state to authenticated email; retain original date key with each in-memory Post without adding an unnecessary persisted field. Navigate to details using original date key and post ID. `post_service.dart:20` currently discards that key, while `bottom_navigation.dart:44` and `mobile_drawer.dart:138` can remove the root gate. Preserve public database field names and legacy timestamp semantics. Use existing Provider patterns with a small post state owner rather than a new state framework.

## Related Code Files
- Create: `mobile-app/mobile-flutter-poc/lib/screens/app_shell.dart` and `lib/providers/posts_provider.dart` (proposed new).
- Modify: `mobile-app/mobile-flutter-poc/lib/main.dart`, `lib/screens/splash_screen.dart`, `lib/screens/sign_in_screen.dart`, `lib/providers/auth_provider.dart`.
- Modify: `mobile-app/mobile-flutter-poc/lib/models/post.dart`, `lib/models/timestamp_data.dart`, `lib/services/post_service.dart`, `lib/utils/post_utils.dart`.
- Modify: `mobile-app/mobile-flutter-poc/lib/screens/dashboard_screen.dart`, `lib/screens/post_list_screen.dart`, `lib/screens/post_details_screen.dart`, `lib/screens/add_post_screen.dart`, `lib/widgets/bottom_navigation.dart`, `lib/widgets/mobile_drawer.dart` for identity/auth callers.
- Modify: `mobile-app/mobile-flutter-poc/lib/utils/token_debug.dart` to remove sensitive diagnostics from runtime usage.
- Delete: None required.

## Implementation Steps
1. Add model/service fixture tests for mixed timestamps, null optional fields, malformed timestamps, and date key differing from timestamp's local date. Provide injectable Firebase seams where necessary.
2. Retain source date key at all parsing points; update all details/edit/delete callers to use it. Keep numeric/string timestamp reads; preserve original timestamp on note edits and avoid silently rewriting malformed history.
3. Centralize auth-gate routing; cancel auth/post subscriptions on disposal and user change, immediately clear old data, and handle unavailable email without attempting database access or uploads.
4. Replace discarded stream errors with explicit loading/data/error states. Await/catch token-related asynchronous failures and remove arbitrary refresh loops and token payload logging. Use UID for analytics identity.
5. Verify rules against emulator fixtures for own-user allowed, cross-user denied, anonymous denied and invalid post ID rejected; inspect deployed configuration separately without changing it.

## Success Criteria
- [x] Legacy posts preserve their original location and data on read and note edit; timezone changes do not change the target path.
- [x] Logout/login and account A→B work after navigation through every tab; no stale state or retained subscription survives user change.
- [x] Read denial, malformed data and missing records have explicit observable states; authentication diagnostics do not expose claims.

## Risk Assessment
An apparently harmless timestamp normalization can move historical dates or break old clients. Keep wire fields stable and avoid production data rewrites. The web and deletion functions consume the existing tree and must remain compatible.
