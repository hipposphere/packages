import 'package:hippo_cli_core/hippo_cli_core.dart';
import 'package:hippo_cli_skills/hippo_cli_skills.dart';
import 'package:path/path.dart' as p;

import '../hippo_command.dart';

final class SkillsValidateCommand extends HippoCommand {
  SkillsValidateCommand(super.contextFactory) {
    argParser.addOption('repo', help: 'Path to the Hipposphere skills repo.');
  }

  @override
  String get name => 'validate';

  @override
  String get description => 'Validate skill metadata and references.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final repo = SkillsRepoResolver(
      environment: ctx.environment,
    ).resolve(explicitPath: argResults!.option('repo'), cwd: ctx.cwd);
    final validator = const SkillsValidator();
    var failed = false;
    for (final dir in resolveSkillDirs(repo, argResults!.rest)) {
      final result = validator.validate(dir);
      if (result.success) {
        ctx.console.ok(p.relative(dir.path, from: repo.path));
      } else {
        failed = true;
        ctx.console.fail(p.relative(dir.path, from: repo.path));
        for (final error in result.errors) {
          ctx.console.stderrLine('  - $error');
        }
      }
    }
    return failed ? HippoExitCode.config : HippoExitCode.ok;
  }
}
