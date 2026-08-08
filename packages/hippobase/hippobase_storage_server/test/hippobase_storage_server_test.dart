import 'dart:io';
import 'dart:typed_data';

import 'package:hippobase_storage_server/hippobase_storage_server.dart';
import 'package:test/test.dart';

void main() {
  group('StorageClient', () {
    test('download stream delegates explicit close', () async {
      var closeCount = 0;
      final download = StorageDownloadStream(
        metadata: const StorageObjectMetadata(),
        body: const Stream<List<int>>.empty(),
        onClose: () {
          closeCount += 1;
        },
      );

      await download.close();

      expect(closeCount, 1);
    });

    test('delegates close to the provider', () async {
      final provider = _CloseTrackingStorageProvider();
      final client = StorageClient(provider: provider);

      await client.close();

      expect(provider.closeCount, 1);
    });

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

      final streamed = await client.downloadStream('workspaces/alpha/report.txt');
      expect(streamed.metadata.contentLength, 5);
      expect(await streamed.body.expand((chunk) => chunk).toList(), 'hello'.codeUnits);

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

      final streamed = await client.downloadStream('exports/data.json');
      expect(await streamed.body.expand((chunk) => chunk).toList(), <int>[123, 125]);

      await client.delete('exports/data.json');
      expect(await client.exists('exports/data.json'), isFalse);
    });
  });
}

final class _CloseTrackingStorageProvider implements StorageProvider {
  var closeCount = 0;

  @override
  Future<void> close() async {
    closeCount += 1;
  }

  @override
  Future<void> delete(String key) {
    throw UnimplementedError();
  }

  @override
  Future<StorageObject> download(String key) {
    throw UnimplementedError();
  }

  @override
  Future<StorageDownloadStream> downloadStream(String key) {
    throw UnimplementedError();
  }

  @override
  Future<bool> exists(String key) {
    throw UnimplementedError();
  }

  @override
  Future<StorageObjectMetadata> getMetadata(String key) {
    throw UnimplementedError();
  }

  @override
  Future<void> upload(
    String key,
    Uint8List bytes, {
    StorageWriteOptions options = const StorageWriteOptions(),
  }) {
    throw UnimplementedError();
  }
}
