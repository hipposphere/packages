import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:hippo_cli_build/hippo_cli_build.dart';
import 'package:hippo_cli_core/hippo_cli_core.dart';

List<String> selectedFlutterTargets(FlutterReleaseConfig config, ArgResults results) {
  if (results.flag('all')) {
    if (results.rest.isNotEmpty) {
      throw UsageException('Do not pass a target when using --all.', '');
    }
    return [
      for (final entry in config.targets.entries)
        if (entry.value.enabled) entry.key,
    ];
  }
  if (results.rest.length != 1) {
    throw UsageException('Expected exactly one target, or pass --all.', '');
  }
  return [results.rest.single];
}

Future<void> writeFlutterGithubOutput(
  HippoCommandContext ctx,
  FlutterReleaseConfig config,
  List<String> targets,
) async {
  final githubOutput = ctx.environment['GITHUB_OUTPUT'];
  if (githubOutput == null || githubOutput.isEmpty) {
    throw const HippoException('GITHUB_OUTPUT is not set.', exitCode: HippoExitCode.usage);
  }
  final buffer = StringBuffer();
  if (targets.length == 1) {
    final targetName = targets.single;
    final target = config.target(targetName);
    buffer
      ..writeln('target=$targetName')
      ..writeln('platform=${target.platform.name}')
      ..writeln('artifact_path=${artifactPaths(config, targetName).join(',')}');
  } else {
    buffer.writeln('artifact_paths<<hippo');
    for (final targetName in targets) {
      for (final path in artifactPaths(config, targetName)) {
        buffer.writeln(path);
      }
    }
    buffer.writeln('hippo');
  }
  await File(githubOutput).writeAsString(buffer.toString(), mode: FileMode.append);
}
