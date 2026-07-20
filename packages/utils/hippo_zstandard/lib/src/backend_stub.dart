import 'dart:typed_data';

Future<Uint8List> compress(
  Uint8List input, {
  required int level,
  required String? webAssetBaseUrl,
}) {
  throw UnsupportedError('hippo_zstandard is not supported on this platform.');
}

Future<Uint8List> decompress(
  Uint8List input, {
  required int maxOutputBytes,
  required String? webAssetBaseUrl,
}) {
  throw UnsupportedError('hippo_zstandard is not supported on this platform.');
}
