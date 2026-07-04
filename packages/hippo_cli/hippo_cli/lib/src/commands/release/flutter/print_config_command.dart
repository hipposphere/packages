import 'package:hippo_cli_build/hippo_cli_build.dart';
import 'package:hippo_cli_core/hippo_cli_core.dart';

import '../../hippo_command.dart';

final class FlutterPrintConfigCommand extends HippoCommand {
  FlutterPrintConfigCommand(super.contextFactory) {
    argParser.addOption(
      'config',
      defaultsTo: 'flutter_release.yaml',
      help: 'Path to release config.',
    );
  }

  @override
  String get name => 'print-config';

  @override
  String get description => 'Print the normalized flutter_release.yaml model.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final builder = FlutterReleaseBuilder(projectRoot: ctx.cwd);
    final config = await builder.loadConfig(path: argResults!.option('config')!);
    ctx.console.writeln(config.toPrettyJson());
    return HippoExitCode.ok;
  }
}
