# Migration release checklist

Code implementation does not establish production readiness. Record evidence for
these checks before an Android/iOS submission.

- [ ] Confirm the published native version, package and source commit against Play
  Console and an installed production app. Source currently declares `5.6` / `17`
  and `asak.pro.pinPotha`; these are not verified live facts.
- [ ] Verify upload key vs Play app-signing certificate, Firebase Android client,
  debug/release SHA fingerprints and iOS bundle/client ID/reversed URL scheme.
- [ ] Use a build number higher than every uploaded build; update display version.
- [ ] Review Android API 24 minimum and iOS 13 minimum against real device distribution.
- [ ] Inspect deployed Database and Storage rules, auth provider configuration and
  App Check state. No rules were deployed by this migration.
- [ ] Run Google sign-in, cancellation, session restore, logout/relogin and A→B
  account switching on real Android/iPhone devices and a Play-installed test build.
- [ ] Verify camera/gallery permissions, cancellation, denied permissions and capture
  on Android/iPhone; verify iPad share popover and note-plus-URL payload.
- [ ] Verify Sinhala notes, small-screen/accessibility text sizes, leap-day calendar,
  month/year navigation, date search and selected-day add/return.
- [ ] Use isolated accounts to exercise rejected writes, connection loss, upload
  success/save rejection, pending writes, cleanup failure/retry and app termination.
  Drafts and cleanup state currently last only for the session.
- [ ] Compare old/new record IDs, date buckets, timestamps, notes and photo URLs;
  confirm existing web/native clients still see compatible data.
- [ ] Install native production app, then upgrade via signed internal Play testing
  without uninstalling. Verify cloud history and login (reauthentication may be needed).
- [ ] Produce signed Android AAB and iOS archive. Unsigned builds prove compilation only.
- [ ] Review current store privacy/account deletion requirements. Web deletion
  callables exist; native mobile account deletion has not been added in this parity pass.
- [ ] Plan staged rollout, monitoring and stop criteria. Preserve known-good native
  source/configuration; recovery release needs a higher build number. Source rollback
  cannot restore deleted user data.

No production deployment, release publication, or backend data rewrite is part of
this implementation session. Runtime device/store checks remain pending unless
separate evidence is attached.
