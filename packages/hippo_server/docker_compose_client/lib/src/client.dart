import 'dart:convert';

import 'errors.dart';
import 'models.dart';
import 'process_runner.dart';

final class DockerComposeClient {
  DockerComposeClient({
    this.executable = 'docker',
    this.defaultTimeout = const Duration(minutes: 5),
    DockerComposeProcessRunner? processRunner,
  }) : processRunner = processRunner ?? const DockerIoComposeProcessRunner();

  final String executable;
  final Duration defaultTimeout;
  final DockerComposeProcessRunner processRunner;

  Future<DockerComposeCommandResult> validate(DockerComposeProject project, {Duration? timeout}) =>
      _run(project, const ['config', '--quiet'], timeout: timeout);

  Future<DockerComposeCommandResult> pull(
    DockerComposeProject project, {
    List<String> services = const [],
    DockerComposePullPolicy? policy,
    bool includeDependencies = false,
    bool ignorePullFailures = false,
    bool quiet = false,
    Duration? timeout,
  }) => _run(project, [
    'pull',
    if (policy != null) ...['--policy', policy.value],
    if (includeDependencies) '--include-deps',
    if (ignorePullFailures) '--ignore-pull-failures',
    if (quiet) '--quiet',
    ..._serviceArguments(services),
  ], timeout: timeout);

  Future<DockerComposeCommandResult> up(
    DockerComposeProject project, {
    List<String> services = const [],
    bool detach = true,
    bool build = false,
    bool forceRecreate = false,
    bool noRecreate = false,
    bool removeOrphans = false,
    bool wait = false,
    Duration? waitTimeout,
    DockerComposeUpPullPolicy? pull,
    Duration? timeout,
  }) {
    if (forceRecreate && noRecreate) {
      throw ArgumentError('forceRecreate and noRecreate cannot both be true.');
    }
    return _run(project, [
      'up',
      if (detach) '--detach',
      if (build) '--build',
      if (forceRecreate) '--force-recreate',
      if (noRecreate) '--no-recreate',
      if (removeOrphans) '--remove-orphans',
      if (wait) '--wait',
      if (waitTimeout != null) ...['--wait-timeout', '${waitTimeout.inSeconds}'],
      if (pull != null) ...['--pull', pull.value],
      ..._serviceArguments(services),
    ], timeout: timeout);
  }

  Future<DockerComposeCommandResult> down(
    DockerComposeProject project, {
    bool removeOrphans = false,
    bool volumes = false,
    DockerComposeDownImages? images,
    Duration? serviceTimeout,
    Duration? timeout,
  }) => _run(project, [
    'down',
    if (removeOrphans) '--remove-orphans',
    if (volumes) '--volumes',
    if (images != null) ...['--rmi', images.value],
    if (serviceTimeout != null) ...['--timeout', '${serviceTimeout.inSeconds}'],
  ], timeout: timeout);

  Future<DockerComposeCommandResult> start(
    DockerComposeProject project, {
    List<String> services = const [],
    Duration? timeout,
  }) => _run(project, ['start', ..._serviceArguments(services)], timeout: timeout);

  Future<DockerComposeCommandResult> stop(
    DockerComposeProject project, {
    List<String> services = const [],
    Duration? serviceTimeout,
    Duration? timeout,
  }) => _run(project, [
    'stop',
    if (serviceTimeout != null) ...['--timeout', '${serviceTimeout.inSeconds}'],
    ..._serviceArguments(services),
  ], timeout: timeout);

  Future<DockerComposeCommandResult> restart(
    DockerComposeProject project, {
    List<String> services = const [],
    Duration? serviceTimeout,
    Duration? timeout,
  }) => _run(project, [
    'restart',
    if (serviceTimeout != null) ...['--timeout', '${serviceTimeout.inSeconds}'],
    ..._serviceArguments(services),
  ], timeout: timeout);

  Future<List<DockerComposeService>> ps(
    DockerComposeProject project, {
    List<String> services = const [],
    bool all = true,
    Duration? timeout,
  }) async {
    final result = await _run(project, [
      'ps',
      if (all) '--all',
      '--format',
      'json',
      ..._serviceArguments(services),
    ], timeout: timeout);
    return _decodeServices(result.stdout);
  }

  Future<DockerComposeCommandResult> logs(
    DockerComposeProject project, {
    List<String> services = const [],
    int? tail,
    DateTime? since,
    bool timestamps = false,
    Duration? timeout,
  }) => _run(project, [
    'logs',
    '--no-color',
    if (tail != null) ...['--tail', '$tail'],
    if (since != null) ...['--since', since.toUtc().toIso8601String()],
    if (timestamps) '--timestamps',
    ..._serviceArguments(services),
  ], timeout: timeout);

  Future<DockerComposeCommandResult> _run(
    DockerComposeProject project,
    List<String> command, {
    Duration? timeout,
  }) async {
    final arguments = [
      'compose',
      '--project-directory',
      project.directory,
      for (final file in project.files) ...['--file', file],
      if (project.projectName != null) ...['--project-name', project.projectName!],
      for (final profile in project.profiles) ...['--profile', profile],
      if (project.envFile != null) ...['--env-file', project.envFile!],
      ...command,
    ];
    final processResult = await processRunner.run(
      DockerComposeProcessRequest(
        executable: executable,
        arguments: arguments,
        workingDirectory: project.directory,
        environment: project.environment,
        timeout: timeout ?? defaultTimeout,
      ),
    );
    final result = DockerComposeCommandResult(
      arguments: List.unmodifiable(arguments),
      exitCode: processResult.exitCode,
      stdout: processResult.stdout,
      stderr: processResult.stderr,
    );
    if (result.exitCode != 0) {
      throw DockerComposeException(
        message: result.stderr.trim().isEmpty
            ? 'Docker Compose command failed.'
            : result.stderr.trim(),
        arguments: result.arguments,
        exitCode: result.exitCode,
        stdout: result.stdout,
        stderr: result.stderr,
      );
    }
    return result;
  }
}

List<String> _serviceArguments(List<String> services) {
  final validName = RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._-]*$');
  for (final service in services) {
    if (!validName.hasMatch(service)) {
      throw ArgumentError.value(service, 'services', 'Invalid Docker Compose service name.');
    }
  }
  return services;
}

List<DockerComposeService> _decodeServices(String source) {
  final value = source.trim();
  if (value.isEmpty) return const [];
  try {
    final decoded = jsonDecode(value);
    if (decoded is List) {
      return decoded
          .map((item) => DockerComposeService.fromJson(jsonObject(item)))
          .toList(growable: false);
    }
    return [DockerComposeService.fromJson(jsonObject(decoded))];
  } on FormatException {
    return value
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => DockerComposeService.fromJson(jsonObject(jsonDecode(line))))
        .toList(growable: false);
  }
}
