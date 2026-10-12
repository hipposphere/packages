import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hippo_test_core/hippo_test_core.dart';

/// Owns a real subprocess; the product entry point prints {"hippo_test_ready":"http://127.0.0.1:PORT"}.
class TestServerProcess {
  TestServerProcess._(this.process, this.recorder);
  final Process process;
  final ScenarioRecorder? recorder;
  final _log = StringBuffer();
  late final Uri baseUri;
  late final Future<void> _stdoutDone, _stderrDone;
  bool _closed = false;
  String get log => _log.toString();
  static Future<TestServerProcess> start({
    required String executable,
    required List<String> arguments,
    required String workingDirectory,
    required TestResources resources,
    ScenarioRecorder? recorder,
    Duration timeout = const Duration(seconds: 90),
  }) async {
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: {'NO_COLOR': '1'},
    );
    final fixture = TestServerProcess._(process, recorder);
    resources.onCleanup(fixture.close);
    final ready = Completer<Uri>();
    fixture._stdoutDone = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach((line) {
          fixture._log.writeln(line);
          try {
            final value = jsonDecode(line);
            if (value is Map && value['hippo_test_ready'] is String && !ready.isCompleted) {
              final uri = Uri.parse(value['hippo_test_ready'] as String);
              if (uri.scheme != 'http' ||
                  !['127.0.0.1', 'localhost', '::1'].contains(uri.host) ||
                  uri.port == 0) {
                throw StateError('Server fixture must use loopback');
              }
              ready.complete(uri);
            }
          } on FormatException {
            /* Ordinary server log line. */
          }
        });
    fixture._stderrDone = process.stderr.transform(utf8.decoder).forEach(fixture._log.write);
    unawaited(
      process.exitCode.then((code) {
        if (!ready.isCompleted) {
          ready.completeError(StateError('Server exited with $code before ready:\n${fixture.log}'));
        }
      }),
    );
    try {
      fixture.baseUri = await ready.future.timeout(timeout);
    } catch (error, stack) {
      await fixture.close();
      Error.throwWithStackTrace(StateError('Server did not start: $error\n${fixture.log}'), stack);
    }
    return fixture;
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    try {
      process.stdin.writeln('stop');
      await process.stdin.close();
      try {
        await process.exitCode.timeout(const Duration(seconds: 5));
      } on TimeoutException {
        process.kill(ProcessSignal.sigkill);
        await process.exitCode;
      }
      await Future.wait([_stdoutDone, _stderrDone]);
    } finally {
      recorder?.attachText('Server process log', log);
    }
  }
}
