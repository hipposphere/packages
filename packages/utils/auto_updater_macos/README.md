# auto_updater_macos

The macOS implementation of `auto_updater`, using Sparkle 2.

Requires macOS 12 or later for both Swift Package Manager and CocoaPods.

## Update lifecycle

Call `setFeedURL` before checking for updates. Sparkle starts on the first call,
unless the application supplies `SUFeedURL` in Info.plist. Initialization errors
are returned as `PlatformException` with code `updater-start-failed`; checks before
startup return `feed-url-not-set`. Invalid native method arguments return
`invalid-argument`.

A manual check made while Sparkle is downloading in the background is queued.
Repeated pending checks are coalesced. The returned future acknowledges acceptance,
not completion: Sparkle shows its UI when ready. Checks can also focus an existing
update dialog. Background checks are skipped while a session is active.

After an automatic download, `before-quit-for-update` means the update is prepared
for installation on quit. The plugin leaves installation to Sparkle, which can
also offer the prepared update on a later manual check.

## Native regression tests

On a Mac with Xcode and Flutter, run:

```sh
tool/test_native.sh /path/to/Sparkle.framework /path/to/FlutterMacOS.framework
```

Both frameworks must include their native binaries, not only headers. The script
builds an XCTest bundle against the real framework APIs and runs startup, queued
checks, delegate and method-channel regressions. CI runs it with Sparkle 2.10.0.
The delegate fixture uses Sparkle's deprecated public appcast-item constructor;
it does not depend on private Sparkle APIs.

Before releasing, also test a signed app against a signed update archive: automatic
download followed by a manual check, a check during download, install and relaunch,
and installation on quit. Use a separate bundle identifier and signing key so the
fixture does not alter a real application's preferences or installed version.

## License

[MIT](./LICENSE)
