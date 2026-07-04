import 'package:hippo_cli_core/hippo_cli_core.dart';
import 'package:hippo_cli_skills/hippo_cli_skills.dart';

import 'mutating_command.dart';

final class SkillsUninstallCommand extends SkillsMutatingCommand {
  SkillsUninstallCommand(super.contextFactory);

  @override
  String get name => 'uninstall';

  @override
  String get description => 'Uninstall Hipposphere skills.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final installOptions = await options(updateRepo: false, requireUpdate: false);
    await SkillsInstaller(processRunner: ctx.processRunner).uninstall(installOptions);
    for (final target in installOptions.targets) {
      ctx.console.ok('skills uninstalled', target.name);
    }
    return HippoExitCode.ok;
  }
}
