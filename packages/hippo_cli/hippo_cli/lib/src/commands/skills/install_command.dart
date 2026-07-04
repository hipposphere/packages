import 'package:hippo_cli_core/hippo_cli_core.dart';
import 'package:hippo_cli_skills/hippo_cli_skills.dart';

import 'mutating_command.dart';

final class SkillsInstallCommand extends SkillsMutatingCommand {
  SkillsInstallCommand(super.contextFactory) {
    argParser.addFlag(
      'update',
      defaultsTo: false,
      help: 'Run git pull --ff-only before installing.',
    );
  }

  @override
  String get name => 'install';

  @override
  String get description => 'Install Hipposphere skills.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final installOptions = await options(
      updateRepo: argResults!.flag('update'),
      requireUpdate: argResults!.flag('update'),
    );
    await ctx.console
        .spinner('Installing skills')
        .during(() => SkillsInstaller(processRunner: ctx.processRunner).install(installOptions));
    for (final target in installOptions.targets) {
      ctx.console.ok('skills installed', target.name);
    }
    return HippoExitCode.ok;
  }
}
