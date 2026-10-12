import 'dart:convert';
import 'dart:io';

import 'package:hippo_test/report.dart';
import 'package:hippo_test/report_io.dart';

/// All remaining arguments are forwarded to `flutter test`.
Future<void> main(List<String> arguments) async {
  final args = [...arguments];
  String option(String flag, String fallback) {
    final index = args.indexOf(flag);
    if (index == -1) return fallback;
    if (index + 1 >= args.length) throw ArgumentError('Missing value for $flag');
    final value = args[index + 1];
    args.removeRange(index, index + 2);
    return value;
  }

  final existing = option('--report', '');
  if (existing.isNotEmpty) {
    final directory = Directory(existing).absolute;
    final data = jsonDecode(
      File('${directory.path}/results.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    await writeTestReport(
      directory: directory,
      cases: (data['cases'] as List).cast<Map<String, dynamic>>(),
      exitCode: data['exitCode'] as int,
      command: '${data['command'] ?? ''}',
      environment: '${data['environment'] ?? ''}',
      runnerLog: File('${directory.path}/runner.log').existsSync()
          ? File('${directory.path}/runner.log').readAsStringSync()
          : '',
    );
    stdout.writeln('Report: ${directory.path}/index.html');
    return;
  }
  if (args.isEmpty || args.contains('--help')) {
    stdout.writeln(
      'Usage: dart run hippo_test [--flutter path] [--output directory] '
      '[--record-steps] <test path> [flutter test options]\n'
      'Rebuild an existing report: dart run hippo_test --report <run directory>\n'
      'Example: dart run hippo_test test/features --update-goldens\n'
      'Run from the Flutter package directory. Each run gets a fresh artifact directory.',
    );
    return;
  }
  final recordSteps = args.remove('--record-steps');
  final flutter = option('--flutter', 'flutter');
  final outputRoot = option('--output', 'build/hippo_test');
  final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
  final directory = Directory('$outputRoot/$stamp').absolute..createSync(recursive: true);
  final testArgs = [
    'test',
    '--machine',
    '--dart-define=HIPPO_TEST_REPORT=${directory.path}',
    if (recordSteps) '--dart-define=HIPPO_TEST_RECORD_STEPS=true',
    ...args,
  ];
  final events = <Map<String, dynamic>>[];
  final log = StringBuffer();
  var code = 1;
  var environment =
      'OS: ${Platform.operatingSystem} (${Platform.operatingSystemVersion})\nDart: ${Platform.version}';
  try {
    final version = await Process.run(flutter, ['--version']);
    environment += '\n${version.stdout}';
    final process = await Process.start(flutter, testArgs);
    final stdoutDone = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach((line) {
          log.writeln(line);
          try {
            final event = jsonDecode(line) as Map<String, dynamic>;
            events.add(event);
            if (event['type'] == 'error') stderr.writeln(event['error']);
            if (event['type'] == 'testStart') stdout.writeln(event['test']['name']);
          } on FormatException {
            stdout.writeln(line);
          } on TypeError {
            stdout.writeln(line);
          }
        });
    final stderrDone = process.stderr.transform(utf8.decoder).forEach((text) {
      log.write(text);
      stderr.write(text);
    });
    code = await process.exitCode;
    await Future.wait([stdoutDone, stderrDone]);
  } catch (error, stack) {
    log.writeln('$error\n$stack');
    stderr.writeln(error);
  }
  final cases =
      directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .map((file) => jsonDecode(file.readAsStringSync()) as Map<String, dynamic>)
          .toList()
        ..sort((a, b) => '${a['id']}'.compareTo('${b['id']}'));
  reconcileRunnerResults(cases, events);
  // A green exit without any executed Hippo case is not useful verification.
  if (code == 0 && (cases.isEmpty || cases.any((test) => test['status'] == 'incomplete'))) code = 1;
  final command = ([
    flutter,
    'test',
    ...args,
  ]).map((arg) => "'${arg.replaceAll("'", "'\\''")}'").join(' ');
  File('${directory.path}/results.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({
      'schemaVersion': 1,
      'exitCode': code,
      'cases': cases,
      'command': 'cd ${Directory.current.path}\n$command',
      'environment': environment,
    }),
  );
  File('${directory.path}/runner.log').writeAsStringSync(log.toString());
  await writeTestReport(
    directory: directory,
    cases: cases,
    exitCode: code,
    command: 'cd ${Directory.current.path}\n$command',
    environment: environment,
    runnerLog: log.toString(),
  );
  stdout.writeln('\nReport: ${directory.path}/index.html');
  exitCode = code;
}
