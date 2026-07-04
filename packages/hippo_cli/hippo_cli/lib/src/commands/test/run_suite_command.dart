import 'package:hippo_cli_build/hippo_cli_build.dart';

import '../hippo_command.dart';

final class RunSuiteCommand extends HippoCommand {
  RunSuiteCommand(super.contextFactory, {required this.name}) {
    argParser
      ..addOption(
        'suite',
        defaultsTo: 'packages/dart_edge_test_suite',
        help: 'Test suite package path.',
      )
      ..addOption('path', defaultsTo: 'test/$name', help: 'Path inside suite package.')
      ..addOption('base-url', help: 'Base URL exposed as TEST_BASE_URL.')
      ..addOption('compose-file', help: 'Docker Compose file to start before tests.')
      ..addOption('compose-project-name', help: 'Docker Compose project name.')
      ..addFlag('compose-down', defaultsTo: true, help: 'Run docker compose down after tests.')
      ..addOption('health-url', help: 'Health URL to poll before tests.')
      ..addOption('health-timeout', defaultsTo: '90', help: 'Health timeout in seconds.')
      ..addOption('reporter', defaultsTo: 'expanded', help: 'dart test reporter.')
      ..addOption('dart', defaultsTo: 'dart', help: 'Dart executable.');
  }

  @override
  final String name;

  @override
  String get description => 'Run the $name test suite.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final baseUrl = argResults!.option('base-url');
    final healthUrl = argResults!.option('health-url') ?? baseUrl;
    return TestSuiteRunner(processRunner: ctx.processRunner).run(
      TestSuiteConfig(
        projectRoot: ctx.cwd,
        suitePath: argResults!.option('suite')!,
        testPath: argResults!.option('path')!,
        environment: baseUrl == null ? const {} : {'TEST_BASE_URL': baseUrl},
        extraTestArguments: argResults!.rest,
        reporter: argResults!.option('reporter')!,
        composeFile: argResults!.option('compose-file'),
        composeProjectName: argResults!.option('compose-project-name'),
        composeDown: argResults!.flag('compose-down'),
        healthUrl: healthUrl == null ? null : Uri.parse(healthUrl),
        healthTimeout: Duration(seconds: int.parse(argResults!.option('health-timeout')!)),
        dartExecutable: argResults!.option('dart')!,
      ),
    );
  }
}
