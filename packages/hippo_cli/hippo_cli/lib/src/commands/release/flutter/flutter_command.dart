import '../../hippo_command.dart';
import 'artifact_paths_command.dart';
import 'build_command.dart';
import 'print_config_command.dart';
import 'publish/publish_command.dart';
import 'signing/signing_command.dart';

final class ReleaseFlutterCommand extends HippoCommand {
  ReleaseFlutterCommand(super.contextFactory) {
    addSubcommand(FlutterBuildCommand(contextFactory));
    addSubcommand(FlutterPublishCommand(contextFactory));
    addSubcommand(FlutterSigningCommand(contextFactory));
    addSubcommand(FlutterArtifactPathsCommand(contextFactory));
    addSubcommand(FlutterPrintConfigCommand(contextFactory));
  }

  @override
  String get name => 'flutter';

  @override
  String get description => 'Build and publish Flutter release artifacts.';
}
