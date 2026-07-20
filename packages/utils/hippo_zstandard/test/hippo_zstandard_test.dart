import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_zstandard/hippo_zstandard.dart';

void main() {
  const codec = HippoZstandard();

  test('round-trips binary data', () async {
    final input = Uint8List.fromList(List<int>.generate(32 * 1024, (index) => index % 251));
    final compressed = await codec.compress(input);
    final decompressed = await codec.decompress(compressed, maxOutputBytes: input.length);

    expect(compressed.take(4), [0x28, 0xb5, 0x2f, 0xfd]);
    expect(decompressed, input);
  });

  test('round-trips empty data', () async {
    final compressed = await codec.compress(Uint8List(0));
    final decompressed = await codec.decompress(compressed, maxOutputBytes: 0);

    expect(decompressed, isEmpty);
  });

  test('enforces the decompressed output limit', () async {
    final compressed = await codec.compress(Uint8List.fromList(List.filled(1024, 65)));

    await expectLater(
      codec.decompress(compressed, maxOutputBytes: 100),
      throwsA(
        isA<HippoZstandardException>().having(
          (error) => error.code,
          'code',
          HippoZstandardError.outputLimitExceeded,
        ),
      ),
    );
  });

  test('rejects invalid compressed data', () async {
    await expectLater(
      codec.decompress(Uint8List.fromList([1, 2, 3]), maxOutputBytes: 1024),
      throwsA(
        isA<HippoZstandardException>().having(
          (error) => error.code,
          'code',
          HippoZstandardError.invalidData,
        ),
      ),
    );
  });
}
