import 'package:hippobase_diagnostics/hippobase_diagnostics.dart';

Future<DiagnosticsStore> createDefaultDiagnosticsStore({
  required String appName,
  required int maxBytesPerFile,
  required int maxFiles,
}) async {
  return InMemoryDiagnosticsStore(maxEntries: 2000);
}
