import 'package:dart_edge_observability/dart_edge_observability.dart';
import 'package:hippobase_diagnostics_server/hippobase_diagnostics_server.dart';
import 'package:test/test.dart';

void main() {
  test('tees Dart Edge JSON logs into diagnostics store', () async {
    final store = InMemoryDiagnosticsStore();
    final logger = DiagnosticsLogger(store: store);
    final jsonLogger = DiagnosticsJsonLogger(logger: logger, source: 'server');

    jsonLogger.log(LogLevel.error, 'failed', fields: const <String, Object?>{'route': '/x'});

    await Future<void>.delayed(Duration.zero);
    final entries = await store.query();

    expect(entries, hasLength(1));
    expect(entries.single.level, DiagnosticLogLevel.error);
    expect(entries.single.source, 'server');
    expect(entries.single.fields, <String, Object?>{'route': '/x'});
  });
}
