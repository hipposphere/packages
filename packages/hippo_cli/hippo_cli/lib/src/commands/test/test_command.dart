import '../hippo_command.dart';
import 'env/env_command.dart';
import 'run_suite_command.dart';

final class TestCommand extends HippoCommand {
  TestCommand(super.contextFactory) {
    addSubcommand(RunSuiteCommand(contextFactory, name: 'routes'));
    addSubcommand(RunSuiteCommand(contextFactory, name: 'e2e'));
    addSubcommand(TestEnvCommand(contextFactory));
  }

  @override
  String get name => 'test';

  @override
  String get description => 'Run route, e2e, and environment tests.';
}
