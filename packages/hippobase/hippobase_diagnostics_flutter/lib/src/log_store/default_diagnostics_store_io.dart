import 'package:hippobase_diagnostics/hippobase_diagnostics.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<DiagnosticsStore> createDefaultDiagnosticsStore({
  required String appName,
  required int maxBytesPerFile,
  required int maxFiles,
}) async {
  final supportDirectory = await getApplicationSupportDirectory();
  final directory = path.join(supportDirectory.path, 'diagnostics', 'logs');
  return FileDiagnosticsStore(
    directoryPath: directory,
    filePrefix: _safeName(appName),
    maxBytesPerFile: maxBytesPerFile,
    maxFiles: maxFiles,
  );
}

String _safeName(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9._-]+'), '_');
}
