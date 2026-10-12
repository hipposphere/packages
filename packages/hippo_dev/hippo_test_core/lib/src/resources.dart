/// Owns test resources and attempts every cleanup even if one fails.
class TestResources {
  final _cleanups = <Future<void> Function()>[];
  bool _closed = false;
  void onCleanup(Future<void> Function() cleanup) {
    if (_closed) throw StateError('Resources are already closed');
    _cleanups.add(cleanup);
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    final errors = <Object>[];
    for (final cleanup in _cleanups.reversed) {
      try {
        await cleanup();
      } catch (error) {
        errors.add(error);
      }
    }
    if (errors.isNotEmpty) throw TestCleanupFailure(errors);
  }
}

class TestCleanupFailure implements Exception {
  TestCleanupFailure(this.errors);
  final List<Object> errors;
  @override
  String toString() => 'Resource cleanup failed: ${errors.join('; ')}';
}
