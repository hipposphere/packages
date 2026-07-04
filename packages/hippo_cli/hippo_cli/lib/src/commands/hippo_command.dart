import 'package:args/command_runner.dart';
import 'package:hippo_cli_core/hippo_cli_core.dart';

typedef HippoCommandContextFactory = Future<HippoCommandContext> Function();

abstract base class HippoCommand extends Command<int> {
  HippoCommand(this.contextFactory);

  final HippoCommandContextFactory contextFactory;

  Future<HippoCommandContext> get context => contextFactory();
}
