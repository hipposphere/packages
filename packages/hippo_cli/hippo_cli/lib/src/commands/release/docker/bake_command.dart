import 'package:hippo_cli_build/hippo_cli_build.dart';
import 'package:hippo_cli_core/hippo_cli_core.dart';

import '../../hippo_command.dart';

final class DockerBakeCommand extends HippoCommand {
  DockerBakeCommand(super.contextFactory) {
    argParser.addOption('config', defaultsTo: 'docker.yaml', help: 'Path to docker.yaml.');
  }

  @override
  String get name => 'bake';

  @override
  String get description => 'Generate and print the Docker Bake file path.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final result = await DockerGenerator(
      projectRoot: ctx.cwd,
    ).generate(configPath: argResults!.option('config')!);
    ctx.console.writeln(result.bakeFile.path);
    return HippoExitCode.ok;
  }
}
