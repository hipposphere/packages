import 'dart:io';

import 'package:hippobase_diagnostics/hippobase_diagnostics.dart';
import 'package:test/test.dart';

void main() {
  test('redacts sensitive fields and bearer tokens', () async {
    final store = InMemoryDiagnosticsStore();
    final logger = DiagnosticsLogger(store: store);

    await logger.error(
      'auth',
      'Bearer abc.def failed',
      fields: <String, Object?>{
        'token': 'secret-token',
        'nested': <String, Object?>{'password': 'secret-password'},
      },
    );

    final entries = await store.query();
    expect(entries, hasLength(1));
    expect(entries.single.message, '<redacted> failed');
    expect(entries.single.fields['token'], '<redacted>');
    expect(entries.single.fields['nested'], <String, Object?>{'password': '<redacted>'});
  });

  test('queries by text, level, and time', () async {
    final store = InMemoryDiagnosticsStore();

    await store.append(
      DiagnosticLogEntry.create(
        id: '1',
        timestamp: DateTime.utc(2026, 1, 1),
        level: DiagnosticLogLevel.info,
        source: 'app',
        message: 'started',
      ),
    );
    await store.append(
      DiagnosticLogEntry.create(
        id: '2',
        timestamp: DateTime.utc(2026, 1, 2),
        level: DiagnosticLogLevel.error,
        source: 'dictation',
        message: 'upload failed',
      ),
    );

    final entries = await store.query(
      DiagnosticLogQuery(
        text: 'upload',
        levels: const <DiagnosticLogLevel>{DiagnosticLogLevel.error},
        from: DateTime.utc(2026, 1, 2),
      ),
    );

    expect(entries.map((entry) => entry.id), <String>['2']);
  });

  test('round-trips ndjson entries', () {
    final entry = DiagnosticLogEntry.create(
      id: 'entry-1',
      timestamp: DateTime.utc(2026, 1, 1),
      level: DiagnosticLogLevel.warning,
      source: 'test',
      message: 'careful',
      fields: const <String, Object?>{'count': 3},
    );

    final ndjson = NdjsonDiagnosticsCodec.encodeEntries(<DiagnosticLogEntry>[entry]);
    final decoded = NdjsonDiagnosticsCodec.decodeEntries(ndjson);

    expect(decoded, hasLength(1));
    expect(decoded.single.id, 'entry-1');
    expect(decoded.single.fields, <String, Object?>{'count': 3});
  });

  test('stores entries in rotating files', () async {
    final directory = await Directory.systemTemp.createTemp('hippobase_diagnostics_test_');
    addTearDown(() => directory.delete(recursive: true));
    final store = FileDiagnosticsStore(
      directoryPath: directory.path,
      filePrefix: 'test',
      maxBytesPerFile: 1,
      maxFiles: 3,
    );

    await store.append(
      DiagnosticLogEntry.create(
        id: 'file-entry-1',
        timestamp: DateTime.utc(2026, 1, 1),
        level: DiagnosticLogLevel.info,
        source: 'file',
        message: 'first',
      ),
    );
    await store.append(
      DiagnosticLogEntry.create(
        id: 'file-entry-2',
        timestamp: DateTime.utc(2026, 1, 2),
        level: DiagnosticLogLevel.error,
        source: 'file',
        message: 'second',
      ),
    );

    final entries = await store.query(const DiagnosticLogQuery(newestFirst: false));
    expect(entries.map((entry) => entry.id), <String>['file-entry-1', 'file-entry-2']);
  });
}
