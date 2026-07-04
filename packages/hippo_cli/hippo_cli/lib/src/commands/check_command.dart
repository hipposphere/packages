import 'hippo_command.dart';
import 'workspace/check_command.dart';

final class CheckCommand extends HippoCommand {
  CheckCommand(super.contextFactory);

  @override
  String get name => 'check';

  @override
  String get description => 'Alias for workspace check.';

  @override
  Future<int> run() => WorkspaceCheckCommand(contextFactory).run();
}
