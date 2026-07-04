import '../hippo_command.dart';
import 'doctor_command.dart';
import 'install_command.dart';
import 'list_command.dart';
import 'uninstall_command.dart';
import 'update_command.dart';
import 'validate_command.dart';

final class SkillsCommand extends HippoCommand {
  SkillsCommand(super.contextFactory) {
    addSubcommand(SkillsInstallCommand(contextFactory));
    addSubcommand(SkillsUpdateCommand(contextFactory));
    addSubcommand(SkillsUninstallCommand(contextFactory));
    addSubcommand(SkillsListCommand(contextFactory));
    addSubcommand(SkillsValidateCommand(contextFactory));
    addSubcommand(SkillsDoctorCommand(contextFactory));
  }

  @override
  String get name => 'skills';

  @override
  String get description => 'Install and validate Hipposphere agent skills.';
}
