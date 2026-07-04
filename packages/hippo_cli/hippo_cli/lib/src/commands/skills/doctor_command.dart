import 'package:hippo_cli_core/hippo_cli_core.dart';
import 'package:hippo_cli_skills/hippo_cli_skills.dart';

import '../hippo_command.dart';

final class SkillsDoctorCommand extends HippoCommand {
  SkillsDoctorCommand(super.contextFactory) {
    argParser.addOption('repo', help: 'Path to the Hipposphere skills repo.');
  }

  @override
  String get name => 'doctor';

  @override
  String get description => 'Check skills repo and install targets.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final repo = SkillsRepoResolver(
      environment: ctx.environment,
    ).resolve(explicitPath: argResults!.option('repo'), cwd: ctx.cwd);
    ctx.console.ok('skills repo', repo.path);
    final targets = defaultTargets(environment: ctx.environment, codex: true, claude: true);
    for (final target in targets) {
      ctx.console.info(target.name, target.directory.path);
    }
    return HippoExitCode.ok;
  }
}
