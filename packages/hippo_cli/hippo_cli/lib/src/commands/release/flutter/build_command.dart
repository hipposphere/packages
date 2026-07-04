import 'package:hippo_cli_build/hippo_cli_build.dart';
import 'package:hippo_cli_core/hippo_cli_core.dart';

import '../../hippo_command.dart';
import 'helpers.dart';

final class FlutterBuildCommand extends HippoCommand {
  FlutterBuildCommand(super.contextFactory) {
    argParser
      ..addOption('config', defaultsTo: 'flutter_release.yaml', help: 'Path to release config.')
      ..addFlag('all', negatable: false, help: 'Build every enabled target.')
      ..addFlag('dry-run', negatable: false, help: 'Print commands without executing them.')
      ..addFlag('github-output', negatable: false, help: 'Append artifact paths to GITHUB_OUTPUT.');
  }

  @override
  String get name => 'build';

  @override
  String get description => 'Run flutter build for configured targets.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final builder = FlutterReleaseBuilder(projectRoot: ctx.cwd, processRunner: ctx.processRunner);
    final config = await builder.loadConfig(path: argResults!.option('config')!);
    final targets = selectedFlutterTargets(config, argResults!);
    for (final target in targets) {
      final exitCode = await builder.build(
        target,
        config: config,
        dryRun: argResults!.flag('dry-run'),
      );
      if (exitCode != 0) {
        return exitCode;
      }
    }
    if (argResults!.flag('github-output')) {
      await writeFlutterGithubOutput(ctx, config, targets);
    }
    return HippoExitCode.ok;
  }
}
