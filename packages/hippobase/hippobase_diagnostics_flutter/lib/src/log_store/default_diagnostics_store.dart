import 'package:hippobase_diagnostics/hippobase_diagnostics.dart';

import 'default_diagnostics_store_stub.dart'
    if (dart.library.io) 'default_diagnostics_store_io.dart'
    as implementation;

Future<DiagnosticsStore> createDefaultDiagnosticsStore({
  required String appName,
  int maxBytesPerFile = 5 * 1024 * 1024,
  int maxFiles = 8,
}) {
  return implementation.createDefaultDiagnosticsStore(
    appName: appName,
    maxBytesPerFile: maxBytesPerFile,
    maxFiles: maxFiles,
  );
}
