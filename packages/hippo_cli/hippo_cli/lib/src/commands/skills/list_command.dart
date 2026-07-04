import 'package:hippo_cli_core/hippo_cli_core.dart';
import 'package:hippo_cli_skills/hippo_cli_skills.dart';
import 'package:path/path.dart' as p;

import '../hippo_command.dart';

final class SkillsListCommand extends HippoCommand {
  SkillsListCommand(super.contextFactory) {
    argParser.addOption('repo', help: 'Path to the Hipposphere skills repo.');
  }

  @override
  String get name => 'list';

  @override
  String get description => 'List available Hipposphere skills.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final repo = SkillsRepoResolver(
      environment: ctx.environment,
    ).resolve(explicitPath: argResults!.option('repo'), cwd: ctx.cwd);
    final rows = [
      for (final dir in resolveSkillDirs(repo, const [])) [p.basename(dir.path), dir.path],
    ];
    ctx.console.table(HippoTable(headers: const ['Skill', 'Path'], rows: rows));
    return HippoExitCode.ok;
  }
}
