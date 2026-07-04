import '../../hippo_command.dart';
import 'bake_command.dart';
import 'build_command.dart';
import 'generate_command.dart';
import 'print_config_command.dart';

final class ReleaseDockerCommand extends HippoCommand {
  ReleaseDockerCommand(super.contextFactory) {
    addSubcommand(DockerGenerateCommand(contextFactory));
    addSubcommand(DockerBuildCommand(contextFactory));
    addSubcommand(DockerBakeCommand(contextFactory));
    addSubcommand(DockerPrintConfigCommand(contextFactory));
  }

  @override
  String get name => 'docker';

  @override
  String get description => 'Generate and build Docker artifacts.';
}
