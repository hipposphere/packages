import 'dart:typed_data';

import 'package:hippobase_storage_models/hippobase_storage_models.dart';
import 'package:test/test.dart';

void main() {
  test('stores bytes and metadata together', () {
    final object = StorageObject(
      bytes: Uint8List.fromList(<int>[1, 2, 3]),
      metadata: const StorageObjectMetadata(
        contentType: 'text/plain',
        contentDisposition: 'inline',
      ),
    );

    expect(object.bytes, orderedEquals(<int>[1, 2, 3]));
    expect(object.metadata.contentType, 'text/plain');
    expect(object.metadata.contentDisposition, 'inline');
  });

  test('converts write options into object metadata', () {
    final metadata = const StorageWriteOptions(
      contentType: 'application/json',
      cacheControl: 'max-age=60',
      metadata: <String, String>{'workspace': 'alpha'},
    ).toMetadata(contentLength: 42);

    expect(metadata.contentLength, 42);
    expect(metadata.contentType, 'application/json');
    expect(metadata.cacheControl, 'max-age=60');
    expect(metadata.metadata, <String, String>{'workspace': 'alpha'});
  });

  test('represents provider-neutral storage byte ranges', () {
    const closed = StorageByteRange.closed(10, 19);
    const openEnded = StorageByteRange.from(20);
    const suffix = StorageByteRange.suffix(30);

    expect((closed.start, closed.end, closed.suffixLength), (10, 19, null));
    expect((openEnded.start, openEnded.end), (20, null));
    expect((suffix.start, suffix.end, suffix.suffixLength), (null, null, 30));
  });

  test('preserves total object length separately from selected length', () {
    const metadata = StorageObjectMetadata(contentLength: 1024, objectLength: 4096);

    expect(metadata.contentLength, 1024);
    expect(metadata.objectLength, 4096);
    expect(metadata.copyWith(contentLength: 512).objectLength, 4096);
  });
}
