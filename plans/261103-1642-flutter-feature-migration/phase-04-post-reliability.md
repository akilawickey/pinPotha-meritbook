---
phase: 4
title: "Harden post operations and recovery"
status: completed
priority: P1
dependencies: [3]
---

# Phase 4: Harden post operations and recovery

## Overview
Resolve CRUD integrity, photo partial failures and list reliability before release validation.

## Requirements
- Functional: Note-only edit preserves all other fields; create/delete report actual outcomes and retain drafts on failure; retries avoid duplicate posts and unmanaged uploads.
- Non-functional: No database/Storage transaction assumptions, no indefinite loading presented as success, and no invalid pagination ranges.

## Architecture
Default to native note-only editing. Preserve record identity and timestamp; update only intended fields rather than replacing the record. Creation allocates stable post/object identities before upload and retains them for retry. Save a photo reference only after upload, and clean up an unreferenced new upload only after a definite rejected commit. Keep uploaded objects while a commit outcome is unknown; reconcile before cleanup. Delete the database record before photo cleanup and report cleanup failure independently. A request timeout means outcome unknown: reconcile the same post identity before retry, since timeout does not cancel the underlying write. Online saves with retained in-session drafts are the provisional baseline; durable offline writes/photos require explicit additional design.

## Related Code Files
- Modify: `mobile-app/mobile-flutter-poc/lib/services/post_service.dart`, `lib/utils/post_utils.dart`, `lib/models/post.dart`, `lib/screens/add_post_screen.dart`, `lib/screens/post_details_screen.dart`, `lib/screens/dashboard_screen.dart`.
- Modify: `mobile-app/mobile-flutter-poc/lib/providers/posts_provider.dart` (introduced by phase 02).
- Create: `mobile-app/mobile-flutter-poc/lib/services/post_draft.dart`, `test/services/post_service_test.dart`, `test/services/post_recovery_test.dart` (implemented draft lifecycle and meaningful tests).
- Delete: None planned.

## Implementation Steps
1. Restrict initial edit UI to native note-only parity. If broader editing is selected, pass old/new source keys, move paths atomically with stable post ID, and cover denied move/retry before exposing it.
2. Add stable IDs and commit-aware save state, preserve draft through failure, prevent duplicate taps, and reconcile unknown outcomes before retry. Separate connection/write failure from empty content and lost authentication.
3. Implement upload compensation and cleanup retry state; use SDK references for existing URLs. If broader photo editing remains enabled, clean the old photo after successful replace or removal, including a null new URL.
4. Repair page-size selection and clamp/reset current page after data changes. Dispose refresh controller and complete refresh based on real result/error rather than elapsed delay.
5. Implement the agreed offline contract; if cached persistence is selected, configure before database use, distinguish cached/pending/committed UI, and test logout/account isolation. Do not advertise durable offline photos without an upload queue.
6. Exercise upload failure, database denial after upload, delete cleanup failure, timeout then late commit, retry, external update and last-page deletion. Record existing last-writer-wins limitations with older clients.

## Success Criteria
- [x] Note edit retains source date, timestamp and photo; deletes target the original source location.
- [x] Failed saves preserve drafts; retries and late commits do not produce duplicate posts; photo cleanup failures are distinguishable from post failure.
- [x] Page size works and shrinking data cannot cause out-of-range pagination.
- [x] Any retained date/photo editing passes atomicity and cleanup tests; otherwise these controls are disabled for initial parity.
- [x] The recommended in-session/online-save baseline is implemented and documented; any expanded offline scope remains an open product question.

## Risk Assessment
Storage and database can disagree after partial failure; do not delete the prior photo before committing its replacement or show a blanket failure after successful record deletion. Avoid adding a backend cleanup service unless observed retry requirements justify it; server-managed durable cleanup would need a separate scoped change.
