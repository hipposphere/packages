import '../hippo_command.dart';
import 'docker/docker_command.dart';
import 'flutter/flutter_command.dart';
import 'version_command.dart';

final class ReleaseCommand extends HippoCommand {
  ReleaseCommand(super.contextFactory) {
    addSubcommand(ReleaseVersionCommand(contextFactory));
    addSubcommand(ReleaseDockerCommand(contextFactory));
    addSubcommand(ReleaseFlutterCommand(contextFactory));
  }

  @override
  String get name => 'release';

  @override
  String get description => 'Build and release Hipposphere artifacts.';
}
