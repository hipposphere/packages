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
}
