import '../hippo_command.dart';
import 'version_command.dart';

final class SelfCommand extends HippoCommand {
  SelfCommand(super.contextFactory) {
    addSubcommand(SelfVersionCommand(contextFactory));
  }

  @override
  String get name => 'self';

  @override
  String get description => 'Inspect or manage the Hippo executable.';
}
