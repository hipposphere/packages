import 'dart:io';
import 'dart:typed_data';

import 'package:hippobase_storage_server/hippobase_storage_server.dart';
import 'package:test/test.dart';

void main() {
  group('StorageClient', () {
    test('delegates upload, metadata, download, exists, and delete', () async {
      final client = StorageClient(provider: InMemoryStorageProvider());

      await client.upload(
        'workspaces/alpha/report.txt',
        Uint8List.fromList('hello'.codeUnits),
        options: const StorageWriteOptions(
          contentType: 'text/plain',
          contentDisposition: 'inline',
          metadata: <String, String>{'owner': 'alpha'},
        ),
      );

      expect(await client.exists('workspaces/alpha/report.txt'), isTrue);

      final metadata = await client.getMetadata('workspaces/alpha/report.txt');
      expect(metadata.contentLength, 5);
      expect(metadata.contentType, 'text/plain');
      expect(metadata.contentDisposition, 'inline');
      expect(metadata.metadata, <String, String>{'owner': 'alpha'});

      final object = await client.download('workspaces/alpha/report.txt');
      expect(object.bytes, orderedEquals('hello'.codeUnits));
      expect(object.metadata.contentLength, 5);

      await client.delete('workspaces/alpha/report.txt');
      expect(await client.exists('workspaces/alpha/report.txt'), isFalse);
    });

    test('rejects empty, absolute, and parent-traversal keys', () async {
      final client = StorageClient(provider: InMemoryStorageProvider());

      expect(() => client.exists(''), throwsArgumentError);
      expect(() => client.exists('/absolute'), throwsArgumentError);
      expect(() => client.exists('workspace/../secret'), throwsArgumentError);
    });
  });

  group('FileSystemStorageProvider', () {
    test('persists bytes and metadata under a base directory', () async {
      final tempDirectory = await Directory.systemTemp.createTemp('hippobase_storage_test_');
      addTearDown(() => tempDirectory.delete(recursive: true));

      final client = StorageClient(
        provider: FileSystemStorageProvider(baseDirectory: tempDirectory),
      );

      await client.upload(
        'exports/data.json',
        Uint8List.fromList(<int>[123, 125]),
        options: const StorageWriteOptions(
          contentType: 'application/json',
          cacheControl: 'no-store',
        ),
      );

      final object = await client.download('exports/data.json');
      expect(object.bytes, orderedEquals(<int>[123, 125]));
      expect(object.metadata.contentLength, 2);
      expect(object.metadata.contentType, 'application/json');
      expect(object.metadata.cacheControl, 'no-store');

      await client.delete('exports/data.json');
      expect(await client.exists('exports/data.json'), isFalse);
    });
  });
}
