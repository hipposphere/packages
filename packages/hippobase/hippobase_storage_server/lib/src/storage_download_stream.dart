import 'dart:async';

import 'package:hippobase_storage_models/hippobase_storage_models.dart';

/// Metadata and a demand-driven body stream for one stored object.
final class StorageDownloadStream {
  const StorageDownloadStream({
    required StorageObjectMetadata metadata,
    required Stream<List<int>> body,
    FutureOr<void> Function()? onClose,
  }) : this._(metadata, body, onClose);

  const StorageDownloadStream._(this.metadata, this.body, this._onClose);

  final StorageObjectMetadata metadata;
  final Stream<List<int>> body;

  final FutureOr<void> Function()? _onClose;

  /// Releases resources acquired before [body] was listened to.
  Future<void> close() async {
    await _onClose?.call();
  }
}
