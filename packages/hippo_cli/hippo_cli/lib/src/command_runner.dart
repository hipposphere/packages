import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:hippo_cli_core/hippo_cli_core.dart';

import 'commands/bench/bench_command.dart';
import 'commands/check_command.dart';
import 'commands/doctor_command.dart';
import 'commands/hippo_command.dart';
import 'commands/release/release_command.dart';
import 'commands/self/self_command.dart';
import 'commands/skills/skills_command.dart';
import 'commands/test/test_command.dart';
import 'commands/workspace/workspace_command.dart';

Future<int> runHippo(
  List<String> arguments, {
  Directory? cwd,
  Map<String, String>? environment,
  StringSink? stdoutSink,
  StringSink? stderrSink,
  bool? stdoutIsTerminal,
  bool? stderrIsTerminal,
  HippoProcessRunner processRunner = const HippoProcessRunner(),
}) async {
  late final CommandRunner<int> runner;
  final globals = _parseGlobalOptions(arguments);

  Future<HippoCommandContext> createContext() async {
    final color = switch (globals.color) {
      'always' => HippoColorMode.always,
      'never' => HippoColorMode.never,
      _ => HippoColorMode.auto,
    };
    return HippoCommandContext.create(
      cwd: cwd,
      environment: environment,
      stdoutSink: stdoutSink,
      stderrSink: stderrSink,
      stdoutIsTerminal: stdoutIsTerminal,
      stderrIsTerminal: stderrIsTerminal,
      processRunner: processRunner,
      colorMode: color,
      ci: globals.ci,
      verbose: globals.verbose,
      quiet: globals.quiet,
      json: globals.json,
    );
  }

  runner = HippoCommandRunner(createContext);
  if (arguments.length == 1 && (arguments.single == '--help' || arguments.single == '-h')) {
    final context = await createContext();
    context.console.writeln(runner.usage);
    return HippoExitCode.ok;
  }
  try {
    return await runner.run(arguments) ?? HippoExitCode.ok;
  } on UsageException catch (error) {
    final context = await createContext();
    context.console.stderrLine(error.message);
    context.console.stderrLine('');
    context.console.stderrLine(error.usage);
    return HippoExitCode.usage;
  } on HippoException catch (error) {
    final context = await createContext();
    context.console.renderException(error);
    return error.exitCode;
  } on Object catch (error, stackTrace) {
    final context = await createContext();
    context.console.stderrLine('hippo failed: $error');
    context.console.trace(stackTrace.toString());
    return HippoExitCode.software;
  }
}

final class HippoCommandRunner extends CommandRunner<int> {
  HippoCommandRunner(this.contextFactory) : super('hippo', 'Hipposphere developer tooling.') {
    argParser
      ..addOption(
        'color',
        allowed: ['auto', 'always', 'never'],
        defaultsTo: 'auto',
        help: 'Control ANSI color output.',
      )
      ..addFlag('ci', negatable: false, help: 'Use deterministic CI-safe output.')
      ..addFlag('verbose', abbr: 'v', negatable: false, help: 'Show diagnostic output.')
      ..addFlag('quiet', abbr: 'q', negatable: false, help: 'Suppress normal output.')
      ..addFlag('json', negatable: false, help: 'Print machine-readable output when supported.');

    addCommand(DoctorCommand(contextFactory));
    addCommand(SelfCommand(contextFactory));
    addCommand(WorkspaceCommand(contextFactory));
    addCommand(ReleaseCommand(contextFactory));
    addCommand(SkillsCommand(contextFactory));
    addCommand(TestCommand(contextFactory));
    addCommand(BenchCommand(contextFactory));
    addCommand(CheckCommand(contextFactory));
  }

  final HippoCommandContextFactory contextFactory;
}

final class _GlobalOptions {
  const _GlobalOptions({
    required this.color,
    required this.ci,
    required this.verbose,
    required this.quiet,
    required this.json,
  });

  final String color;
  final bool ci;
  final bool verbose;
  final bool quiet;
  final bool json;
}

_GlobalOptions _parseGlobalOptions(List<String> arguments) {
  var color = 'auto';
  var ci = false;
  var verbose = false;
  var quiet = false;
  var json = false;

  for (var index = 0; index < arguments.length; index++) {
    final argument = arguments[index];
    if (!argument.startsWith('-')) {
      break;
    }
    switch (argument) {
      case '--ci':
        ci = true;
      case '--verbose':
      case '-v':
        verbose = true;
      case '--quiet':
      case '-q':
        quiet = true;
      case '--json':
        json = true;
      case '--color':
        if (index + 1 < arguments.length) {
          color = arguments[++index];
        }
      default:
        if (argument.startsWith('--color=')) {
          color = argument.substring('--color='.length);
        }
    }
  }

  return _GlobalOptions(color: color, ci: ci, verbose: verbose, quiet: quiet, json: json);
}
