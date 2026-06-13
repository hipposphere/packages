import 'dart:io';

import 'config.dart';
import 'console.dart';
import 'process_runner.dart';
import 'theme.dart';

final class HippoCommandContext {
  const HippoCommandContext({
    required this.cwd,
    required this.console,
    required this.processRunner,
    required this.config,
    required this.environment,
    required this.ci,
    required this.verbose,
    required this.quiet,
    required this.json,
  });

  final Directory cwd;
  final HippoConsole console;
  final HippoProcessRunner processRunner;
  final HippoConfig config;
  final Map<String, String> environment;
  final bool ci;
  final bool verbose;
  final bool quiet;
  final bool json;

  static Future<HippoCommandContext> create({
    Directory? cwd,
    Map<String, String>? environment,
    HippoColorMode colorMode = HippoColorMode.auto,
    bool ci = false,
    bool verbose = false,
    bool quiet = false,
    bool json = false,
    StringSink? stdoutSink,
    StringSink? stderrSink,
    bool? stdoutIsTerminal,
    bool? stderrIsTerminal,
    HippoProcessRunner processRunner = const HippoProcessRunner(),
  }) async {
    final env = environment ?? Platform.environment;
    final resolvedCwd = cwd ?? Directory.current;
    final resolvedCi = ci || isCiEnvironment(env);
    return HippoCommandContext(
      cwd: resolvedCwd,
      environment: env,
      processRunner: processRunner,
      config: await HippoConfig.load(cwd: resolvedCwd, environment: env),
      ci: resolvedCi,
      verbose: verbose,
      quiet: quiet,
      json: json,
      console: HippoConsole(
        stdoutSink: stdoutSink,
        stderrSink: stderrSink,
        stdoutIsTerminal: stdoutIsTerminal,
        stderrIsTerminal: stderrIsTerminal,
        colorMode: colorMode,
        ci: resolvedCi,
        verbose: verbose,
        quiet: quiet,
      ),
    );
  }
}

bool isCiEnvironment(Map<String, String> environment) {
  const keys = ['CI', 'GITHUB_ACTIONS', 'BUILDKITE', 'GITLAB_CI', 'CIRCLECI', 'TF_BUILD'];
  for (final key in keys) {
    final value = environment[key];
    if (value != null && value.isNotEmpty && value.toLowerCase() != 'false') {
      return true;
    }
  }
  return false;
}
