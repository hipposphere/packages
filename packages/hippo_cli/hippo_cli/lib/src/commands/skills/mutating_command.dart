import 'package:hippo_cli_skills/hippo_cli_skills.dart';

import '../hippo_command.dart';

abstract base class SkillsMutatingCommand extends HippoCommand {
  SkillsMutatingCommand(super.contextFactory) {
    argParser
      ..addOption('repo', help: 'Path to the Hipposphere skills repo.')
      ..addFlag('codex', defaultsTo: true, help: 'Target Codex skills.')
      ..addFlag('claude', defaultsTo: true, help: 'Target Claude Code skills.');
  }

  Future<SkillsInstallOptions> options({
    required bool updateRepo,
    required bool requireUpdate,
  }) async {
    final ctx = await context;
    final repo = SkillsRepoResolver(
      environment: ctx.environment,
    ).resolve(explicitPath: argResults!.option('repo'), cwd: ctx.cwd);
    final targets = defaultTargets(
      environment: ctx.environment,
      codex: argResults!.flag('codex'),
      claude: argResults!.flag('claude'),
    );
    if (targets.isEmpty) {
      usageException('No skill targets selected.');
    }
    return SkillsInstallOptions(
      repoRoot: repo,
      targets: targets,
      updateRepo: updateRepo,
      requireUpdate: requireUpdate,
    );
  }
}
