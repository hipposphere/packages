import 'dart:io' as io;

import 'package:hippo_cli/hippo_cli.dart';

Future<void> main(List<String> arguments) async {
  io.exitCode = await runHippo(arguments);
}
