import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hippobase_diagnostics_flutter/hippobase_diagnostics_flutter.dart';

void main() {
  test('loads, filters, exports, and clears logs', () async {
    final store = InMemoryDiagnosticsStore();
    final diagnostics = HippobaseFlutterDiagnostics(
      appName: 'test',
      store: store,
      logger: DiagnosticsLogger(store: store),
    );
    final controller = DiagnosticsLogController(diagnostics: diagnostics, autoRefresh: false);
    addTearDown(controller.dispose);

    await diagnostics.logger.info('app', 'started');
    await diagnostics.logger.error('dictation', 'upload failed');

    await controller.load();
    expect(controller.entries, hasLength(2));

    controller.updateQuery(const DiagnosticLogQuery(text: 'upload'));
    await Future<void>.delayed(Duration.zero);
    expect(controller.entries, hasLength(1));
    expect(controller.entries.single.source, 'dictation');

    final export = await controller.export();
    expect(export, isA<DiagnosticsLogTextExportResult>());
    expect((export! as DiagnosticsLogTextExportResult).ndjson, contains('upload failed'));

    await controller.clear();
    expect(controller.entries, isEmpty);
  });

  test('auto refresh coalesces bursty log entries', () async {
    final store = _GatedDiagnosticsStore();
    final diagnostics = HippobaseFlutterDiagnostics(
      appName: 'test',
      store: store,
      logger: DiagnosticsLogger(store: store),
    );
    final controller = DiagnosticsLogController(
      diagnostics: diagnostics,
      autoRefreshDebounce: Duration.zero,
    );
    addTearDown(controller.dispose);

    store.pauseQueries();
    await diagnostics.logger.info('app', 'one');
    await store.firstQueryStarted.future;

    await diagnostics.logger.info('app', 'two');
    await diagnostics.logger.info('app', 'three');
    await Future<void>.delayed(Duration.zero);

    expect(store.queryCount, 1);

    store.resumeQueries();
    await _waitUntil(() => store.queryCount == 2 && controller.entries.length == 3);
    expect(store.maxConcurrentQueries, 1);
  });
}

final class _GatedDiagnosticsStore implements DiagnosticsStore {
  final InMemoryDiagnosticsStore _inner = InMemoryDiagnosticsStore();
  final Completer<void> firstQueryStarted = Completer<void>();

  Completer<void>? _queryGate;
  int queryCount = 0;
  int _activeQueries = 0;
  int maxConcurrentQueries = 0;

  @override
  Stream<DiagnosticLogEntry> get entries => _inner.entries;

  @override
  Future<void> append(DiagnosticLogEntry entry) {
    return _inner.append(entry);
  }

  @override
  Future<void> clear() {
    return _inner.clear();
  }

  @override
  Future<List<DiagnosticLogEntry>> query([
    DiagnosticLogQuery query = const DiagnosticLogQuery(),
  ]) async {
    queryCount++;
    _activeQueries++;
    if (_activeQueries > maxConcurrentQueries) {
      maxConcurrentQueries = _activeQueries;
    }
    if (!firstQueryStarted.isCompleted) {
      firstQueryStarted.complete();
    }
    try {
      await _queryGate?.future;
      return await _inner.query(query);
    } finally {
      _activeQueries--;
    }
  }

  void pauseQueries() {
    _queryGate = Completer<void>();
  }

  void resumeQueries() {
    final gate = _queryGate;
    _queryGate = null;
    if (gate != null && !gate.isCompleted) {
      gate.complete();
    }
  }
}

Future<void> _waitUntil(bool Function() predicate) async {
  for (var i = 0; i < 50; i++) {
    if (predicate()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Timed out waiting for condition.');
}
