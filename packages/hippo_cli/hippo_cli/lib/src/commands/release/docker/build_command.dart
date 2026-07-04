import 'package:hippo_cli_build/hippo_cli_build.dart';

import '../../hippo_command.dart';

final class DockerBuildCommand extends HippoCommand {
  DockerBuildCommand(super.contextFactory) {
    argParser
      ..addOption('config', defaultsTo: 'docker.yaml', help: 'Path to docker.yaml.')
      ..addFlag('push', negatable: false, help: 'Pass --push to docker buildx build.');
  }

  @override
  String get name => 'build';

  @override
  String get description => 'Generate and run docker buildx build.';

  @override
  Future<int> run() async {
    final ctx = await context;
    if (argResults!.rest.length != 1) {
      usageException('Expected exactly one image name.');
    }
    final imageName = argResults!.rest.single;
    return DockerGenerator(projectRoot: ctx.cwd).build(
      imageName: imageName,
      configPath: argResults!.option('config')!,
      push: argResults!.flag('push'),
      processRunner: ctx.processRunner,
    );
  }
}
