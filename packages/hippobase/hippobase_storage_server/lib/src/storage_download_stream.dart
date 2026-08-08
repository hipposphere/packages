import 'package:hippobase_storage_models/hippobase_storage_models.dart';

/// Metadata and a demand-driven body stream for one stored object.
final class StorageDownloadStream {
  const StorageDownloadStream({required this.metadata, required this.body});

  final StorageObjectMetadata metadata;
  final Stream<List<int>> body;
}
