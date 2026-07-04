import '../../hippo_command.dart';
import 'compose_command.dart';

final class TestEnvCommand extends HippoCommand {
  TestEnvCommand(super.contextFactory) {
    addSubcommand(ComposeCommand(contextFactory, name: 'up'));
    addSubcommand(ComposeCommand(contextFactory, name: 'down'));
  }

  @override
  String get name => 'env';

  @override
  String get description => 'Manage Docker Compose test environments.';
}
