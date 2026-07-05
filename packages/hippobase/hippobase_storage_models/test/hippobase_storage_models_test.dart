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
}
