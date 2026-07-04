import '../hippo_command.dart';
import 'check_command.dart';

final class WorkspaceCommand extends HippoCommand {
  WorkspaceCommand(super.contextFactory) {
    addSubcommand(WorkspaceCheckCommand(contextFactory));
  }

  @override
  String get name => 'workspace';

  @override
  String get description => 'Inspect and validate the current workspace.';
}
