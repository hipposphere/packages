import 'dart:io';

import 'package:hippo_cli_core/hippo_cli_core.dart';
import 'package:hippo_cli_skills/hippo_cli_skills.dart';

import 'hippo_command.dart';

final class DoctorCommand extends HippoCommand {
  DoctorCommand(super.contextFactory);

  @override
  String get name => 'doctor';

  @override
  String get description => 'Check local Hipposphere tooling health.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final workspace = await const WorkspaceDetector().detect(ctx.cwd);
    ctx.console.writeln(ctx.console.theme.bold('Hippo doctor'));
    ctx.console.writeln();
    ctx.console.ok('workspace', workspace.description);
    ctx.console.info('root', workspace.root.path);
    await _checkExecutable(ctx, 'dart', ['--version']);
    await _checkExecutable(ctx, 'flutter', ['--version', '--machine'], optional: true);
    await _checkExecutable(ctx, 'docker', ['--version'], optional: true);
    await _checkExecutable(ctx, 'git', ['--version'], optional: true);
    _checkSkillsRepo(ctx);
    return HippoExitCode.ok;
  }

  Future<void> _checkExecutable(
    HippoCommandContext ctx,
    String executable,
    List<String> args, {
    bool optional = false,
  }) async {
    try {
      final result = await ctx.processRunner.run(executable, args, workingDirectory: ctx.cwd.path);
      if (result.success) {
        ctx.console.ok(
          executable,
          _firstLine(result.stdout.isEmpty ? result.stderr : result.stdout),
        );
      } else if (optional) {
        ctx.console.warn(executable, 'available but returned ${result.exitCode}');
      } else {
        ctx.console.fail(executable, 'returned ${result.exitCode}');
      }
    } on ProcessException {
      if (optional) {
        ctx.console.warn(executable, 'not found');
      } else {
        ctx.console.fail(executable, 'not found');
      }
    }
  }

  void _checkSkillsRepo(HippoCommandContext ctx) {
    try {
      final repo = SkillsRepoResolver(environment: ctx.environment).resolve(cwd: ctx.cwd);
      ctx.console.ok('skills repo', repo.path);
    } on HippoException catch (error) {
      ctx.console.warn('skills repo', error.message);
    }
  }
}

String _firstLine(String text) {
  final lines = text.trim().split('\n');
  return lines.isEmpty ? '' : lines.first;
}
