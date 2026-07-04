import 'package:hippo_cli_build/hippo_cli_build.dart';
import 'package:hippo_cli_core/hippo_cli_core.dart';

import '../../hippo_command.dart';

final class DockerPrintConfigCommand extends HippoCommand {
  DockerPrintConfigCommand(super.contextFactory) {
    argParser.addOption('config', defaultsTo: 'docker.yaml', help: 'Path to docker.yaml.');
  }

  @override
  String get name => 'print-config';

  @override
  String get description => 'Print the normalized docker.yaml model.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final config = await DockerGenerator(
      projectRoot: ctx.cwd,
    ).loadConfig(path: argResults!.option('config')!);
    ctx.console.writeln(config.toPrettyJson());
    return HippoExitCode.ok;
  }
}
