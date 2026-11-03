---
phase: 3
title: "Restore calendar and navigation parity"
status: completed
priority: P1
dependencies: [2]
---

# Phase 3: Restore calendar and navigation parity

## Overview
Restore the native calendar-led experience while reusing the Flutter post grid and form.

## Requirements
- Functional: Home/Add/View/Settings, month/year controls, post-day indicators, selected-day list/add, note/date search, photo-link sharing, profile/logout, and actual installed version.
- Non-functional: Preserve selected-day/tab state, avoid navigation-stack growth, and support Sinhala text, small screens and iPad share presentation.

## Architecture
The app shell owns tab and selected-date state. Add a calendar Home with an inline calendar grid; repurpose the existing dashboard grid as View without renaming files unnecessarily. Calendar routes to existing `PostListScreen` and Add receives `initialDate`. Calendar indicators and selected-day lists filter the same shared posts using the native timestamp-based display date for valid legacy timestamps. For malformed timestamps, use the parsed source date key as a visibly marked fallback. Adapt PostListScreen to this shared filter rather than querying a potentially different date bucket. Flag source-key mismatches, and always address writes through original source keys. Use a real installed-package version for settings. See native `DashboardActivity.java:105`, `:174`, `:243` and Flutter `dashboard_screen.dart:104`/`post_details_screen.dart:154` in the analysis report.

## Related Code Files
- Create: `mobile-app/mobile-flutter-poc/lib/screens/calendar_screen.dart`, `lib/screens/settings_screen.dart` (implemented; calendar widget remains inline to avoid an unnecessary abstraction).
- Modify: `mobile-app/mobile-flutter-poc/lib/screens/app_shell.dart`, `lib/providers/posts_provider.dart` (introduced by phase 02).
- Modify: `mobile-app/mobile-flutter-poc/lib/widgets/bottom_navigation.dart`, `lib/widgets/mobile_drawer.dart`, `lib/screens/dashboard_screen.dart`, `lib/screens/post_list_screen.dart`, `lib/screens/add_post_screen.dart`, `lib/screens/post_details_screen.dart`, `lib/utils/date_utils.dart`.
- Modify: `mobile-app/mobile-flutter-poc/pubspec.yaml`, `pubspec.lock` for selected calendar/version dependencies only if needed.
- Delete: None planned.

## Implementation Steps
1. Implement four stable tabs and root-owned selected date. Repeated tab selection must not push duplicate routes; handle back and unsaved forms consistently.
2. Add month/year calendar controls, one/multiple-post indicators, selected-day summary/date list, empty-day add action, and return-to-selected-day after successful create.
3. Reuse View grid; add formatted-date matching alongside note search and distinguish no search matches from an empty account.
4. Add settings with real version/build, profile access and logout confirmation. Remove the hardcoded About version and drawer-dependent navigation from screens without a drawer.
5. Share available note plus photo URL; handle photo-only posts and verify iPad share anchoring. Resolve legacy date bounds explicitly rather than enforcing Flutter's 2000..today range silently.
6. Add focused widget/journey tests for calendar selection, leap dates, search, tabs, settings and share payload construction.

## Success Criteria
- [x] Feature matrix gaps for calendar, date navigation, tabs, settings, date search and photo-link sharing are closed.
- [x] Selecting a day, creating a post and returning keeps that day selected and updates its indicator.
- [x] Profile/logout remain available; version/build uses the cross-platform package-info API (widget contract tested; physical-device verification remains in phase 05); Sinhala notes render and search correctly.

## Risk Assessment
A new visual layout should not alter existing data semantics. Keep source date separate from display date and cover timezone changes. Future native dates or dates before 2000 must not trigger Flutter date-picker assertions.
