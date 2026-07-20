# hippo_zstandard

Cross-platform Zstandard compression for Hipposphere Flutter applications.

- Android, iOS, Linux, macOS, and Windows use verified, precompiled Rust
  libraries selected through a Dart native-asset hook.
- Web uses the same Rust ABI compiled to WebAssembly and runs it in a dedicated
  worker.
- Decompression always requires an explicit output limit.

```dart
final zstandard = HippoZstandard();
final compressed = await zstandard.compress(input);
final restored = await zstandard.decompress(
  compressed,
  maxOutputBytes: 64 * 1024 * 1024,
);
```

## Prebuilt native assets

Applications consuming `hippo_zstandard` do not need Rust. The hook downloads
and caches SHA-256-verified binaries for:

- Android arm, arm64, and x64
- iOS arm64 devices plus arm64 and x64 simulators
- Linux arm64 and x64
- macOS arm64 and x64
- Windows arm64 and x64

The GitHub Actions native-artifact workflow builds these binaries with the Rust
version pinned in `native/rust-toolchain.toml` and publishes them under the Rust
crate version from `native/Cargo.toml`. Native source or ABI changes must bump
that crate version before the package is released.

Package developers can explicitly build from source with a hook user-define in
the consuming workspace root. That is the only mode requiring `rustup`:

```yaml
hooks:
  user_defines:
    hippo_zstandard:
      build_from_source: true
```

For local artifact testing, the same block accepts `prebuilt_base_url` and a
relative `native_cache` path. Hook configuration uses user-defines because Dart
hooks intentionally filter arbitrary environment variables.

The checked-in web module can be rebuilt with:

```sh
dart run tool/build_web.dart
```

The release workflow replaces the checked-in module with the matching verified
WebAssembly artifact before publishing the Dart package.

Regenerate Dart FFI bindings after changing the C header with:

```sh
dart run ffigen --config ffigen.yaml
```
