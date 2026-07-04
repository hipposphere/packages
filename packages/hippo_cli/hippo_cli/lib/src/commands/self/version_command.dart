import 'package:hippo_cli_core/hippo_cli_core.dart';

import '../hippo_command.dart';

final class SelfVersionCommand extends HippoCommand {
  SelfVersionCommand(super.contextFactory);

  @override
  String get name => 'version';

  @override
  String get description => 'Print the Hippo CLI version.';

  @override
  Future<int> run() async {
    final ctx = await context;
    ctx.console.writeln('0.1.0');
    return HippoExitCode.ok;
  }
}
