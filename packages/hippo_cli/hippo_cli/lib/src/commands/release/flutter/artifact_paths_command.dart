import 'package:hippo_cli_build/hippo_cli_build.dart';
import 'package:hippo_cli_core/hippo_cli_core.dart';

import '../../hippo_command.dart';

final class FlutterArtifactPathsCommand extends HippoCommand {
  FlutterArtifactPathsCommand(super.contextFactory) {
    argParser.addOption(
      'config',
      defaultsTo: 'flutter_release.yaml',
      help: 'Path to release config.',
    );
  }

  @override
  String get name => 'artifact-paths';

  @override
  String get description => 'Print default artifact upload paths.';

  @override
  Future<int> run() async {
    final ctx = await context;
    if (argResults!.rest.length != 1) {
      usageException('Expected exactly one target.');
    }
    final builder = FlutterReleaseBuilder(projectRoot: ctx.cwd);
    final config = await builder.loadConfig(path: argResults!.option('config')!);
    ctx.console.writeln(artifactPaths(config, argResults!.rest.single).join('\n'));
    return HippoExitCode.ok;
  }
}
