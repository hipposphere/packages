import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'errors.dart';

final class DockerComposeProcessRequest {
  const DockerComposeProcessRequest({
    required this.executable,
    required this.arguments,
    required this.workingDirectory,
    required this.environment,
    required this.timeout,
  });

  final String executable;
  final List<String> arguments;
  final String workingDirectory;
  final Map<String, String> environment;
  final Duration timeout;
}

final class DockerComposeProcessResult {
  const DockerComposeProcessResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final int exitCode;
  final String stdout;
  final String stderr;
}

abstract interface class DockerComposeProcessRunner {
  Future<DockerComposeProcessResult> run(DockerComposeProcessRequest request);
}

final class DockerIoComposeProcessRunner implements DockerComposeProcessRunner {
  const DockerIoComposeProcessRunner();

  @override
  Future<DockerComposeProcessResult> run(DockerComposeProcessRequest request) async {
    final process = await Process.start(
      request.executable,
      request.arguments,
      workingDirectory: request.workingDirectory,
      environment: request.environment,
      includeParentEnvironment: true,
      runInShell: false,
    );
    final stdout = process.stdout.transform(utf8.decoder).join();
    final stderr = process.stderr.transform(utf8.decoder).join();
    try {
      final exitCode = await process.exitCode.timeout(request.timeout);
      return DockerComposeProcessResult(
        exitCode: exitCode,
        stdout: await stdout,
        stderr: await stderr,
      );
    } on TimeoutException {
      process.kill();
      await process.exitCode;
      await Future.wait([stdout, stderr]);
      throw DockerComposeTimeoutException(arguments: request.arguments, timeout: request.timeout);
    }
  }
}
