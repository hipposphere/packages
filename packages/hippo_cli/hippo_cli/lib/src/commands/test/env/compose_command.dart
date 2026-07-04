import 'package:hippo_cli_build/hippo_cli_build.dart';

import '../../hippo_command.dart';

final class ComposeCommand extends HippoCommand {
  ComposeCommand(super.contextFactory, {required this.name}) {
    argParser
      ..addOption(
        'compose-file',
        defaultsTo: 'environment/compose.yaml',
        help: 'Docker Compose file.',
      )
      ..addOption('compose-project-name', help: 'Docker Compose project name.');
  }

  @override
  final String name;

  @override
  String get description =>
      name == 'up' ? 'Start the test environment.' : 'Stop the test environment.';

  @override
  Future<int> run() async {
    final ctx = await context;
    return TestSuiteRunner(processRunner: ctx.processRunner).compose(
      projectRoot: ctx.cwd,
      action: name == 'up' ? ComposeAction.up : ComposeAction.down,
      composeFile: argResults!.option('compose-file')!,
      composeProjectName: argResults!.option('compose-project-name'),
    );
  }
}
