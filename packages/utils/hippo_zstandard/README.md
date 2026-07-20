# hippo_zstandard

Cross-platform Zstandard compression for Hipposphere Flutter applications.

- Android, iOS, Linux, macOS, and Windows use a Rust library built through Dart
  native-asset hooks.
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

## Toolchain

Native consumers need `rustup`; the exact Rust version is pinned in
`native/rust-toolchain.toml`. The checked-in web module can be rebuilt with:

```sh
dart run tool/build_web.dart
```

Regenerate Dart FFI bindings after changing the C header with:

```sh
dart run ffigen --config ffigen.yaml
```
