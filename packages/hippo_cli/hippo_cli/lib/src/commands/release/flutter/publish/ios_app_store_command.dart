import 'package:hippo_cli_build/hippo_cli_build.dart';

import '../../../hippo_command.dart';

final class FlutterPublishIosAppStoreCommand extends HippoCommand {
  FlutterPublishIosAppStoreCommand(super.contextFactory) {
    argParser
      ..addOption('config', defaultsTo: 'flutter_release.yaml', help: 'Path to release config.')
      ..addOption('target', help: 'Release target to publish.')
      ..addFlag('dry-run', negatable: false, help: 'Print commands without executing them.');
  }

  @override
  String get name => 'ios-app-store';

  @override
  String get description => 'Upload an iOS IPA to App Store Connect.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final builder = FlutterReleaseBuilder(projectRoot: ctx.cwd, processRunner: ctx.processRunner);
    final config = await builder.loadConfig(path: argResults!.option('config')!);
    return builder.publishIosAppStore(
      targetName: argResults!.option('target') ?? config.targets.keys.first,
      config: config,
      dryRun: argResults!.flag('dry-run'),
    );
  }
}
