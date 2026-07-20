import 'dart:typed_data';

import 'backend_stub.dart'
    if (dart.library.io) 'backend_native.dart'
    if (dart.library.js_interop) 'backend_web.dart'
    as backend;

/// A Zstandard operation failed.
final class HippoZstandardException implements Exception {
  const HippoZstandardException(this.code, {this.details});

  /// The portable category reported by the Rust backend.
  final HippoZstandardError code;

  /// Optional platform detail useful for diagnostics.
  final String? details;

  @override
  String toString() =>
      ['HippoZstandardException: ${code.message}', if (details != null) details].join(' ');
}

/// Portable errors returned by the native and WebAssembly backends.
enum HippoZstandardError {
  invalidData('The input is not valid Zstandard data.'),
  outputLimitExceeded('The decompressed data exceeds the configured output limit.'),
  internal('The Zstandard backend failed internally.'),
  invalidArgument('A Zstandard argument was invalid.');

  const HippoZstandardError(this.message);

  /// A stable human-readable error description.
  final String message;
}

/// Cross-platform Zstandard compression.
final class HippoZstandard {
  /// Creates a Zstandard codec.
  ///
  /// [webAssetBaseUrl] can relocate the package's worker and WebAssembly files
  /// when a web host serves Flutter assets from a custom URL.
  const HippoZstandard({this.webAssetBaseUrl});

  /// Optional base URL for web assets, including a trailing slash.
  final String? webAssetBaseUrl;

  /// Compresses [input] at the requested Zstandard [level].
  Future<Uint8List> compress(Uint8List input, {int level = 3}) {
    if (level < -8 || level > 4) {
      throw ArgumentError.value(level, 'level', 'must be between -8 and 4');
    }
    return backend.compress(input, level: level, webAssetBaseUrl: webAssetBaseUrl);
  }

  /// Decompresses [input], rejecting output larger than [maxOutputBytes].
  Future<Uint8List> decompress(Uint8List input, {required int maxOutputBytes}) {
    if (maxOutputBytes < 0) {
      throw ArgumentError.value(maxOutputBytes, 'maxOutputBytes', 'must not be negative');
    }
    return backend.decompress(
      input,
      maxOutputBytes: maxOutputBytes,
      webAssetBaseUrl: webAssetBaseUrl,
    );
  }
}
