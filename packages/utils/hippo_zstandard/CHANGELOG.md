## 0.1.2

- Align Android native libraries to 16 KB pages, including builds using NDK r27.
- Select native artifact version 0.1.1 so cached 4 KB binaries are not reused.
- Check Android ELF load-segment alignment before publishing native artifacts.

## 0.1.1

- Update the native asset hook to Code Assets 2 and the Hippolabs Rust toolchain
  registry so applications can use it alongside current Dart S3 and SQL packages.

## 0.1.0

- Add Zstandard compression and bounded decompression on native and web platforms.
- Download verified precompiled native libraries through Dart code-asset hooks,
  with explicit source builds reserved for package development.
- Run the WebAssembly backend in a dedicated web worker.
