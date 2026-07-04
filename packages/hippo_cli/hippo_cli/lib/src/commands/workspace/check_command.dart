import 'package:hippo_cli_core/hippo_cli_core.dart';

import '../hippo_command.dart';

final class WorkspaceCheckCommand extends HippoCommand {
  WorkspaceCheckCommand(super.contextFactory);

  @override
  String get name => 'check';

  @override
  String get description => 'Check that the current workspace is recognizable.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final workspace = await const WorkspaceDetector().detect(ctx.cwd);
    if (workspace.type == HippoWorkspaceType.unknown) {
      throw HippoException(
        'Unknown workspace.',
        expected: 'Expected a Dart pub workspace, Dart package, or Hipposphere skills repo.',
        exitCode: HippoExitCode.config,
      );
    }
    ctx.console.ok('workspace', workspace.description);
    ctx.console.info('root', workspace.root.path);
    return HippoExitCode.ok;
  }
}
