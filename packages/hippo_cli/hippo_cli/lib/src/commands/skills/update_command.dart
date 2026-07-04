import 'package:hippo_cli_core/hippo_cli_core.dart';
import 'package:hippo_cli_skills/hippo_cli_skills.dart';

import 'mutating_command.dart';

final class SkillsUpdateCommand extends SkillsMutatingCommand {
  SkillsUpdateCommand(super.contextFactory);

  @override
  String get name => 'update';

  @override
  String get description => 'Update the skills repo and install skills.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final installOptions = await options(updateRepo: true, requireUpdate: true);
    await ctx.console
        .spinner('Updating skills')
        .during(() => SkillsInstaller(processRunner: ctx.processRunner).install(installOptions));
    for (final target in installOptions.targets) {
      ctx.console.ok('skills updated', target.name);
    }
    return HippoExitCode.ok;
  }
}
