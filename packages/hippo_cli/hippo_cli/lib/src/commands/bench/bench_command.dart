import '../hippo_command.dart';
import 'server_command.dart';

final class BenchCommand extends HippoCommand {
  BenchCommand(super.contextFactory) {
    addSubcommand(ServerBenchCommand(contextFactory));
  }

  @override
  String get name => 'bench';

  @override
  String get description => 'Run reproducible benchmark suites.';
}
