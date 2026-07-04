import 'package:hippo_cli_build/hippo_cli_build.dart';

import '../../../hippo_command.dart';

final class FlutterSigningIosCommand extends HippoCommand {
  FlutterSigningIosCommand(super.contextFactory) {
    argParser
      ..addOption('config', defaultsTo: 'flutter_release.yaml', help: 'Path to release config.')
      ..addOption('target', help: 'Release target to validate.')
      ..addFlag('dry-run', negatable: false, help: 'Print commands without executing them.');
  }

  @override
  String get name => 'ios';

  @override
  String get description => 'Validate iOS signing material.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final builder = FlutterReleaseBuilder(projectRoot: ctx.cwd, processRunner: ctx.processRunner);
    final config = await builder.loadConfig(path: argResults!.option('config')!);
    return builder.installIosSigningMaterial(
      targetName: argResults!.option('target'),
      config: config,
      dryRun: argResults!.flag('dry-run'),
    );
  }
}
