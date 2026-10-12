import 'dart:convert';
import 'dart:io';

/// Run from this package with a Flutter executable path as the first argument.
Future<void> main(List<String> args) async {
  final flutter = args.isEmpty ? 'flutter' : args.first;
  final keep = args.contains('--keep');
  final output = Directory.systemTemp.createTempSync('hippo-test-probe-');
  const baseline = 'test/fixtures/goldens/probe.png';
  try {
    for (final changed in [false, true]) {
      final process = await Process.run(Platform.resolvedExecutable, [
        'run',
        'hippo_test',
        '--flutter',
        flutter,
        '--output',
        output.path,
        '--record-steps',
        'test/fixtures/failure_probe.dart',
        if (!changed) '--update-goldens',
        if (changed) '--dart-define=HIPPO_PROBE_CHANGED=true',
      ]);
      if ((process.exitCode == 0) == changed) {
        throw StateError(
          'Unexpected exit ${process.exitCode}: ${process.stdout}\n${process.stderr}',
        );
      }
    }
    final runs = output.listSync().whereType<Directory>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    final results = jsonDecode(File('${runs.last.path}/results.json').readAsStringSync());
    final cases = (results['cases'] as List).cast<Map<String, dynamic>>();
    if (cases.length != 2 || cases.any((test) => test['status'] != 'failed')) {
      throw StateError('Both golden and teardown failures must be reported: $cases');
    }
    final checkpoint =
        (cases.firstWhere((test) => test['id'] == 'probe.golden')['checkpoints'] as List).first;
    for (final key in ['actual', 'expected', 'isolatedDiff', 'maskedDiff']) {
      if (!File('${runs.last.path}/${checkpoint[key]}').existsSync()) {
        throw StateError('Missing $key artifact');
      }
    }
    for (final name in ['viewer.js', 'viewer.css', 'index.html']) {
      if (File('${runs.last.path}/$name').lengthSync() < 100) {
        throw StateError('Missing viewer artifact: $name');
      }
    }
    if ((cases.firstWhere((test) => test['id'] == 'probe.golden')['frames'] as List).isEmpty) {
      throw StateError('A failed step must retain its replay frame');
    }
    if (keep) stdout.writeln('Retained probe: ${runs.last.path}');
    stdout.writeln(
      'Verified baseline update, golden mismatch, image diffs, exit status and teardown failure.',
    );
  } finally {
    if (File(baseline).existsSync()) File(baseline).deleteSync();
    if (!keep) output.deleteSync(recursive: true);
    final failures = Directory('test/fixtures/failures');
    if (failures.existsSync()) failures.deleteSync(recursive: true);
  }
}
