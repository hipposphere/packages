import '../../../hippo_command.dart';
import 'ios_command.dart';

final class FlutterSigningCommand extends HippoCommand {
  FlutterSigningCommand(super.contextFactory) {
    addSubcommand(FlutterSigningIosCommand(contextFactory));
  }

  @override
  String get name => 'signing';

  @override
  String get description => 'Install Flutter signing material.';
}
