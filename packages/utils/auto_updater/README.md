# Auto Updater

Federated Flutter desktop updater backed by Sparkle on macOS, WinSparkle on
Windows, and signed AppImages on Linux.

## Usage

```dart
await autoUpdater.setFeedURL(
  'https://updates.example.com/appcast.xml',
  ed25519PublicKey: const String.fromEnvironment(
    'AUTO_UPDATER_ED_PUBLIC_KEY',
  ),
);
await autoUpdater.checkForUpdates();
```

The public key is required on Linux and ignored by the native Sparkle
implementations. It is the base64-encoded 32-byte public key emitted by
Sparkle's `generate_keys`.

## Shared appcast

A single feed may contain separate items for macOS, Windows, Linux x86_64, and
Linux ARM64. Linux items must use `sparkle:os="linux"` and `hippo:arch`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<rss
  version="2.0"
  xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"
  xmlns:hippo="https://hippolabs.org/xml-namespaces/auto-updater">
  <channel>
    <item>
      <title>Version 1.4.0</title>
      <sparkle:version>140</sparkle:version>
      <sparkle:shortVersionString>1.4.0</sparkle:shortVersionString>
      <sparkle:releaseNotesLink>
        https://example.com/releases/1.4.0
      </sparkle:releaseNotesLink>
      <enclosure
        url="https://example.com/MyApp-1.4.0-x86_64.AppImage"
        length="12345678"
        type="application/vnd.appimage"
        sparkle:os="linux"
        hippo:arch="x86_64"
        sparkle:edSignature="BASE64_SIGNATURE" />
    </item>
  </channel>
</rss>
```

Use `aarch64` for ARM64. Each platform and architecture gets its own item.
`sparkle:version` must match the monotonically increasing Flutter build number.
Only the default Sparkle channel is selected.

All feed, artifact, redirect, and release-note URLs must use HTTPS.

## Linux packaging and signing

Linux self-updates are supported only when the application is running as an
AppImage from a user-writable directory. The AppImage should contain the
standard Flutter Linux bundle, including the plugin's
`auto_updater_linux_helper` executable.

Sign the final AppImage using an exported Sparkle Ed25519 private key:

```sh
dart run auto_updater:sign_update \
  MyApp-1.4.0-x86_64.AppImage \
  --ed-key-file sparkle_private_key
```

On Linux the private key file must be a current Sparkle export: a
base64-encoded 32-byte Ed25519 seed. Sparkle's legacy 96-byte hashed-key format
cannot be used by the pure-Dart signer; sign the AppImage with Sparkle's native
`sign_update` on macOS when retaining such a key. Use `--ed-key-file -` to read
the key from standard input. The command prints the `sparkle:edSignature` and
`length` attributes for the enclosure.

The Linux updater never elevates privileges. Normal Linux bundles, Flatpak,
deb, rpm, and system-wide installations are not self-updated.
