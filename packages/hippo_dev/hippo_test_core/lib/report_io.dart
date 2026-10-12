import 'dart:io';
import 'dart:isolate';

import 'report.dart';

/// Copy the versioned viewer bundle into each report. No CDN, fetch, or server.
Future<void> writeTestReport({
  required Directory directory,
  required List<Map<String, dynamic>> cases,
  required int exitCode,
  required String command,
  required String environment,
  required String runnerLog,
}) async {
  final library = await Isolate.resolvePackageUri(Uri.parse('package:hippo_test_core/report.dart'));
  if (library == null) throw StateError('Cannot locate the hippo_test viewer bundle');
  for (final name in ['viewer.js', 'viewer.css', 'THIRD_PARTY_NOTICES.txt']) {
    final source = File.fromUri(library.resolve('../assets/$name'));
    if (!source.existsSync()) {
      throw StateError(
        'Missing $name. Build hippo_test_viewer/tool/build.dart before releasing hippo_test_core.',
      );
    }
    await source.copy('${directory.path}/$name');
  }
  await File('${directory.path}/index.html').writeAsString(
    renderTestReport(
      cases: cases,
      exitCode: exitCode,
      command: command,
      environment: environment,
      runnerLog: runnerLog,
    ),
  );
}
