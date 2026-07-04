import 'dart:io';

import 'package:hippo_cli_build/hippo_cli_build.dart';
import 'package:hippo_cli_core/hippo_cli_core.dart';
import 'package:path/path.dart' as p;

import '../hippo_command.dart';

final class ReleaseVersionCommand extends HippoCommand {
  ReleaseVersionCommand(super.contextFactory) {
    argParser
      ..addFlag('json', negatable: false, help: 'Print JSON output.')
      ..addFlag('github-output', negatable: false, help: 'Append values to GITHUB_OUTPUT.');
  }

  @override
  String get name => 'version';

  @override
  String get description => 'Read a package version from pubspec.yaml.';

  @override
  String get invocation => 'hippo release version [--json] [--github-output] <package-path>';

  @override
  Future<int> run() async {
    final ctx = await context;
    if (argResults!.rest.length != 1) {
      usageException('Expected exactly one package path.');
    }
    final packagePath = argResults!.rest.single;
    final output = await PackageVersionOutput.read(
      Directory(p.isAbsolute(packagePath) ? packagePath : p.join(ctx.cwd.path, packagePath)),
    );
    if (argResults!.flag('github-output')) {
      final githubOutput = ctx.environment['GITHUB_OUTPUT'];
      if (githubOutput == null || githubOutput.isEmpty) {
        usageException('GITHUB_OUTPUT is not set.');
      }
      await File(githubOutput).writeAsString(output.toEnv(), mode: FileMode.append);
    }
    ctx.console.write(argResults!.flag('json') || ctx.json ? output.toJson() : output.toEnv());
    return HippoExitCode.ok;
  }
}
