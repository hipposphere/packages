import 'dart:io';

import 'package:hippo_cli_build/hippo_cli_build.dart';
import 'package:hippo_cli_core/hippo_cli_core.dart';

import '../../hippo_command.dart';

final class DockerGenerateCommand extends HippoCommand {
  DockerGenerateCommand(super.contextFactory) {
    argParser
      ..addOption('config', defaultsTo: 'docker.yaml', help: 'Path to docker.yaml.')
      ..addFlag(
        'github-output',
        negatable: false,
        help: 'Append generated paths to GITHUB_OUTPUT.',
      );
  }

  @override
  String get name => 'generate';

  @override
  String get description => 'Generate Dockerfiles and Docker Bake targets.';

  @override
  Future<int> run() async {
    final ctx = await context;
    if (argResults!.rest.length > 1) {
      usageException('Expected at most one image name.');
    }
    final selectedImage = argResults!.rest.length == 1 ? argResults!.rest.single : null;
    final result = await ctx.console
        .spinner('Generating Docker artifacts')
        .during(
          () => DockerGenerator(
            projectRoot: ctx.cwd,
          ).generate(configPath: argResults!.option('config')!, selectedImage: selectedImage),
        );
    for (final image in result.images) {
      ctx.console.ok('generated ${image.name}', image.dockerfile.path);
    }
    ctx.console.ok('bake file', result.bakeFile.path);
    if (argResults!.flag('github-output')) {
      final githubOutput = ctx.environment['GITHUB_OUTPUT'];
      if (githubOutput == null || githubOutput.isEmpty) {
        usageException('GITHUB_OUTPUT is not set.');
      }
      if (result.images.length != 1) {
        usageException('Expected exactly one selected image when using --github-output.');
      }
      final image = result.images.single;
      await File(githubOutput).writeAsString(
        'image=${image.name}\ndockerfile=${image.dockerfile.path}\ncontext=${image.context.path}\n',
        mode: FileMode.append,
      );
    }
    return HippoExitCode.ok;
  }
}
