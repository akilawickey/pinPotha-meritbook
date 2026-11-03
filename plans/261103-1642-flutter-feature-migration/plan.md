---
title: "PinPotha native Android to Flutter feature migration"
status: in-progress
created: 261103-1642
issue: "none"
mode: hard
blockedBy: []
blocks: []
---

# PinPotha native Android to Flutter feature migration

## Overview
Migrate the behavior of `mobile-app/pinPotha realtime db` into the existing `mobile-app/mobile-flutter-poc` app, preserving existing accounts and posts. The Flutter app already implements much of the post workflow, but lacks Android packaging and several native features, and has data and authentication defects to resolve before release. This is a repository-based analysis and implementation plan, not verification of the currently published binary.

## Goals / Non-Goals
- **Goals:** Restore calendar, selected-day creation, searchable post browsing, details, note editing, deletion, photo-link sharing, profile, logout, settings/version, and Home/Add/View/Settings navigation; enable Android while retaining iOS; preserve existing Firebase contracts; verify an upgrade from the published Android app.
- **Non-Goals:** Implement code during this analysis; migrate to Firestore or UID-based database paths; redesign the web app; deploy rules or functions; publish a release; automatically add all web-only features.

## Approach
Use hard mode because app identity, shared production data, native platform setup, and failure recovery cross several boundaries. Reuse Flutter's models, Firebase utilities, Provider authentication, image picker, post form, list cards, and date-list screen. Introduce only a small authenticated navigation shell and explicit post location; avoid a new backend or a wholesale state-management rewrite.

Keep `pinpotha-1295`, `posts/{email-with-dots-replaced-by-commas}/{dd-MM-yyyy}/{postId}`, and `photos/{objectId}`. Preserve the `postId`, `note`, `photoUrl`, and `timeStamp.server_time` fields, including support for legacy numeric and string timestamps. Store the original date key in memory when parsing a post; never derive its write/delete path from a timezone-converted timestamp. Default to native parity: edit the note without changing date or photo. If broader Flutter editing is retained, require an atomic date move and safe photo lifecycle before enabling it.

Create an authenticated app shell that owns navigation and one user-scoped post subscription. Restore the calendar as Home; reuse the existing Flutter dashboard grid as View. Expose date lists from the calendar and carry selected dates into Add. Preserve the authentication gate through logout/relogin and cancel subscriptions on user change. Start with the existing whole-user read pattern for parity; Flutter pagination is currently display-only, so measure large accounts before claiming backend pagination.

Detailed evidence, feature mapping, failure analysis, external documentation, validation cases, and scope limits are in [migration analysis](reports/migration-analysis.md). Implementation progress and executed checks are recorded in [implementation verification](reports/implementation-verification.md). Phases 02–04 are implemented and covered by local tests; phase 01 live configuration checks and phase 05 signed/device validation remain open. Exact store identity, signing, deployed Firebase rules, supported OS floor, and production version remain unverified.

## Phases
| # | Phase | Status | Priority | Depends on |
|---|-------|--------|----------|------------|
| 01 | [Confirm baseline and platform setup](phase-01-platform-baseline.md) | in-progress | P1 | - |
| 02 | [Preserve data and authentication contracts](phase-02-data-auth.md) | completed | P1 | 01 |
| 03 | [Restore calendar and navigation parity](phase-03-feature-parity.md) | completed | P1 | 02 |
| 04 | [Harden post operations and recovery](phase-04-post-reliability.md) | completed | P1 | 03 |
| 05 | [Validate compatibility and prepare rollout](phase-05-release-validation.md) | in-progress | P1 | 04 |

## Risks & Mitigations
| Risk | Impact | Mitigation |
|------|--------|------------|
| Local source differs from production | high | Compare Play Console version/package/certificate and actual installed journeys before locking parity. |
| Wrong application ID/signing identity creates a separate app or blocks updates | high | Verify `asak.pro.pinPotha` against the live listing; preserve the existing signing arrangement and use a build number above the highest uploaded one. |
| Date-derived writes modify the wrong location or duplicate posts | high | Carry original date keys; preserve timestamps on note edit; lock date editing by default or atomically move both paths. |
| Authentication gate removed, stale subscriptions survive logout | high | Central gate and scoped subscription ownership; test logout/login/account switching and navigation from every tab. |
| Upload succeeds but database commit fails | med | Retain draft, reuse stable post/object IDs on retry, compensate for unreferenced uploads; report storage cleanup failures separately. |
| Backend rules differ from repository | high | Inspect deployed rules and test compatible fixtures in an isolated Firebase environment; do not weaken rules for the new client. |
| Flutter/plugin minimum OS exceeds native minSdk 16 | med | Select and record a tested SDK/plugin matrix; quantify device exclusion before release. |
| Old clients write during migration | med | Preserve schema and timestamp on note-only edits; test coexistence; document existing last-writer-wins behavior. |

## Acceptance Criteria
- [ ] A versioned native-vs-Flutter feature matrix is verified against the actual published Android app.
- [ ] Existing users sign in and see the same post IDs, notes, dates, and photo URLs without a data-copy job.
- [ ] Calendar month/year navigation, post indicators, selected-day lists, date propagation, four tabs, profile, logout, and real settings/version work on Android and iOS.
- [ ] Search matches both note content and formatted date; sharing includes the photo URL when present.
- [ ] Note editing and deletion target the stored source date key, including timezone and malformed-timestamp cases.
- [ ] Logout/login/account-switch flows retain the auth gate and expose no stale previous-user UI or subscriptions.
- [ ] Meaningful tests, analyzer, Android release bundle, and iOS build/device checks pass; planned commands are recorded in phase 05.
- [ ] A signed internal-track upgrade over the published native Android app succeeds and retains access to cloud data.
- [ ] Offline behavior and broader edit scope are explicit; unsupported behavior is not advertised.
- [ ] Release identity, live rules, signing, store requirements, and rollback procedure are recorded before production rollout.

## Open Questions
1. Does the currently published Android build correspond to local native version `5.6` / code `17`, package `asak.pro.pinPotha`? Firebase configuration also contains `org.leafylanka.pinpotha`; this is not proof of the store package.
2. Is the first deliverable Android replacement with iOS kept working (recommended assumption), or an iOS release first?
3. Keep native note-only editing for initial parity (recommended), or retain Flutter date/photo editing and implement its additional integrity guarantees?
4. What offline behavior is required? Proposed initial behavior is explicit online save plus retained in-session draft; persistent cached reading can be added and tested if required. Durable offline photo upload is separate work.
5. Which SDK/plugin versions and minimum OS versions should be supported after checking the current dependency matrix and user device distribution?
6. Are account deletion and other web-only account features required in the first mobile release? Review live store requirements before release; these are not native feature-parity work.
