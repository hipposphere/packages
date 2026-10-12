import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hippo_test_core/hippo_test_core.dart';

/// A private PostgreSQL cluster. Requires initdb/postgres on PATH (or binDirectory).
class TestPostgres {
  TestPostgres._(this.directory, this.port);
  final Directory directory;
  final int port;
  Process? _process;
  Future<void>? _output;
  bool _closed = false;
  final _log = StringBuffer();
  Uri get uri => Uri(
    scheme: 'postgresql',
    userInfo: 'hippo_test',
    host: '127.0.0.1',
    port: port,
    path: '/postgres',
    queryParameters: {'sslmode': 'disable'},
  );
  String get log => _log.toString();
  static Future<TestPostgres> start({
    required TestResources resources,
    String? binDirectory,
  }) async {
    final reservation = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final cluster = TestPostgres._(
      await Directory.systemTemp.createTemp('hippo-test-postgres-'),
      reservation.port,
    );
    resources.onCleanup(cluster.close);
    await reservation.close();
    String binary(String name) => binDirectory == null ? name : '$binDirectory/$name';
    final init = await Process.run(binary('initdb'), [
      '-D',
      '${cluster.directory.path}/data',
      '--username=hippo_test',
      '--auth=trust',
      '--no-locale',
      '--encoding=UTF8',
    ]);
    if (init.exitCode != 0) throw StateError('initdb failed: ${init.stderr}');
    final process = cluster._process = await Process.start(binary('postgres'), [
      '-D',
      '${cluster.directory.path}/data',
      '-p',
      '${cluster.port}',
      '-c',
      'listen_addresses=127.0.0.1',
      '-c',
      'unix_socket_directories=${cluster.directory.path}',
      '-c',
      'shared_buffers=16MB',
      '-c',
      'max_connections=20',
    ]);
    final ready = Completer<void>();
    void line(String value) {
      cluster._log.writeln(value);
      if (value.contains('database system is ready to accept connections') && !ready.isCompleted) {
        ready.complete();
      }
    }

    cluster._output = Future.wait([
      process.stdout.transform(utf8.decoder).transform(const LineSplitter()).forEach(line),
      process.stderr.transform(utf8.decoder).transform(const LineSplitter()).forEach(line),
    ]);
    unawaited(
      process.exitCode.then((code) {
        if (!ready.isCompleted) {
          ready.completeError(StateError('PostgreSQL exited with $code: ${cluster.log}'));
        }
      }),
    );
    await ready.future.timeout(const Duration(seconds: 30));
    return cluster;
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    final process = _process;
    if (process != null) {
      process.kill(ProcessSignal.sigterm);
      try {
        await process.exitCode.timeout(const Duration(seconds: 5));
      } on TimeoutException {
        process.kill(ProcessSignal.sigkill);
        await process.exitCode;
      }
      await _output;
    }
    if (directory.existsSync()) await directory.delete(recursive: true);
  }
}
