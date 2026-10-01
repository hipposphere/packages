## 1.1.0

* Fix Sparkle sessions remaining stalled after an automatic download. The
  install-on-quit delegate now returns false, retaining installation on quit
  while allowing later manual checks to offer installation and relaunch.
* Queue and coalesce manual checks while Sparkle is busy. Execute them on the
  next main-loop turn after Sparkle becomes ready.
* Start Sparkle only after a feed is available, unless Info.plist has SUFeedURL.
* Skip background checks during an active session.
* Report missing feeds, startup failures and invalid method arguments as
  PlatformExceptions instead of silently succeeding or crashing.
* Add native regression tests compiled against Sparkle and FlutterMacOS.

## 1.0.1

* feat: Add Swift Package Manager support.
* chore: Upgrade Sparkle dependency to `>=2.9.2 <3.0`.
* chore: Require macOS `10.15`, Dart `>=3.11.0`, and Flutter `>=3.41.0`.

## 1.0.0

* First major release.

## 0.2.0

* First release.
