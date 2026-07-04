import '../../../hippo_command.dart';
import 'ios_app_store_command.dart';

final class FlutterPublishCommand extends HippoCommand {
  FlutterPublishCommand(super.contextFactory) {
    addSubcommand(FlutterPublishIosAppStoreCommand(contextFactory));
  }

  @override
  String get name => 'publish';

  @override
  String get description => 'Publish Flutter release artifacts.';
}
