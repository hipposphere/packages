import 'dart:io';

import 'package:hippo_cli_core/hippo_cli_core.dart';
import 'package:path/path.dart' as p;

final class TestSuiteConfig {
  const TestSuiteConfig({
    required this.projectRoot,
    required this.suitePath,
    required this.testPath,
    this.environment = const {},
    this.extraTestArguments = const [],
    this.reporter = 'expanded',
    this.composeFile,
    this.composeProjectName,
    this.composeDown = true,
    this.healthUrl,
    this.healthTimeout = const Duration(seconds: 90),
    this.dartExecutable = 'dart',
  });

  final Directory projectRoot;
  final String suitePath;
  final String testPath;
  final Map<String, String> environment;
  final List<String> extraTestArguments;
  final String reporter;
  final String? composeFile;
  final String? composeProjectName;
  final bool composeDown;
  final Uri? healthUrl;
  final Duration healthTimeout;
  final String dartExecutable;
}

final class TestSuiteRunner {
  const TestSuiteRunner({this.processRunner = const HippoProcessRunner()});

  final HippoProcessRunner processRunner;

  Future<int> run(TestSuiteConfig config) async {
    if (config.composeFile != null) {
      final up = await compose(
        projectRoot: config.projectRoot,
        action: ComposeAction.up,
        composeFile: config.composeFile!,
        composeProjectName: config.composeProjectName,
      );
      if (up != 0) {
        return up;
      }
    }
    try {
      if (config.healthUrl != null) {
        await waitForHealth(config.healthUrl!, timeout: config.healthTimeout);
      }
      return processRunner.inherit(
        config.dartExecutable,
        ['test', config.testPath, '--reporter', config.reporter, ...config.extraTestArguments],
        workingDirectory: p.join(config.projectRoot.path, config.suitePath),
        environment: config.environment,
      );
    } finally {
      if (config.composeFile != null && config.composeDown) {
        await compose(
          projectRoot: config.projectRoot,
          action: ComposeAction.down,
          composeFile: config.composeFile!,
          composeProjectName: config.composeProjectName,
        );
      }
    }
  }

  Future<int> compose({
    required Directory projectRoot,
    required ComposeAction action,
    required String composeFile,
    String? composeProjectName,
  }) {
    return processRunner.inherit('docker', [
      'compose',
      '--file',
      composeFile,
      if (composeProjectName != null) ...['--project-name', composeProjectName],
      if (action == ComposeAction.up) ...[
        'up',
        '--build',
        '--detach',
      ] else ...[
        'down',
        '--remove-orphans',
      ],
    ], workingDirectory: projectRoot.path);
  }
}

enum ComposeAction { up, down }

Future<void> waitForHealth(Uri url, {required Duration timeout}) async {
  final client = HttpClient();
  final deadline = DateTime.now().add(timeout);
  try {
    while (DateTime.now().isBefore(deadline)) {
      try {
        final request = await client.getUrl(url);
        final response = await request.close();
        await response.drain<void>();
        if (response.statusCode >= 200 && response.statusCode < 500) {
          return;
        }
      } on Object {
        // Retry until the timeout expires.
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
  } finally {
    client.close(force: true);
  }
  throw HippoException(
    'Timed out waiting for $url.',
    expected: 'Expected the test environment to become healthy within ${timeout.inSeconds}s.',
    exitCode: HippoExitCode.unavailable,
  );
}
