import 'dart:convert';
import 'dart:io';

final class HippoProcessResult {
  const HippoProcessResult({required this.exitCode, required this.stdout, required this.stderr});

  final int exitCode;
  final String stdout;
  final String stderr;

  bool get success => exitCode == 0;
}

final class HippoProcessRunner {
  const HippoProcessRunner();

  Future<HippoProcessResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
  }) async {
    final result = await Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
    );
    return HippoProcessResult(
      exitCode: result.exitCode,
      stdout: _decode(result.stdout),
      stderr: _decode(result.stderr),
    );
  }

  Future<int> inherit(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
  }) async {
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      mode: ProcessStartMode.inheritStdio,
    );
    return process.exitCode;
  }
}

String shellCommand(List<String> command) {
  return command.map(_quoteShellArgument).join(' ');
}

String _quoteShellArgument(String value) {
  if (value.isEmpty) {
    return "''";
  }
  if (RegExp(r'^[A-Za-z0-9_./:=@+-]+$').hasMatch(value)) {
    return value;
  }
  return "'${value.replaceAll("'", r"'\''")}'";
}

String _decode(Object value) {
  if (value is String) {
    return value;
  }
  if (value is List<int>) {
    return utf8.decode(value);
  }
  return value.toString();
}
