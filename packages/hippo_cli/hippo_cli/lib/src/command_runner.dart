import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:hippo_cli_build/hippo_cli_build.dart';
import 'package:hippo_cli_core/hippo_cli_core.dart';
import 'package:hippo_cli_skills/hippo_cli_skills.dart';
import 'package:path/path.dart' as p;

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

  final Future<HippoCommandContext> Function() contextFactory;
}

abstract base class HippoCommand extends Command<int> {
  HippoCommand(this.contextFactory);

  final Future<HippoCommandContext> Function() contextFactory;

  Future<HippoCommandContext> get context => contextFactory();
}

final class DoctorCommand extends HippoCommand {
  DoctorCommand(super.contextFactory);

  @override
  String get name => 'doctor';

  @override
  String get description => 'Check local Hipposphere tooling health.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final workspace = await const WorkspaceDetector().detect(ctx.cwd);
    ctx.console.writeln(ctx.console.theme.bold('Hippo doctor'));
    ctx.console.writeln();
    ctx.console.ok('workspace', workspace.description);
    ctx.console.info('root', workspace.root.path);
    await _checkExecutable(ctx, 'dart', ['--version']);
    await _checkExecutable(ctx, 'flutter', ['--version', '--machine'], optional: true);
    await _checkExecutable(ctx, 'docker', ['--version'], optional: true);
    await _checkExecutable(ctx, 'git', ['--version'], optional: true);
    _checkSkillsRepo(ctx);
    return HippoExitCode.ok;
  }

  Future<void> _checkExecutable(
    HippoCommandContext ctx,
    String executable,
    List<String> args, {
    bool optional = false,
  }) async {
    try {
      final result = await ctx.processRunner.run(executable, args, workingDirectory: ctx.cwd.path);
      if (result.success) {
        ctx.console.ok(
          executable,
          _firstLine(result.stdout.isEmpty ? result.stderr : result.stdout),
        );
      } else if (optional) {
        ctx.console.warn(executable, 'available but returned ${result.exitCode}');
      } else {
        ctx.console.fail(executable, 'returned ${result.exitCode}');
      }
    } on ProcessException {
      if (optional) {
        ctx.console.warn(executable, 'not found');
      } else {
        ctx.console.fail(executable, 'not found');
      }
    }
  }

  void _checkSkillsRepo(HippoCommandContext ctx) {
    try {
      final repo = SkillsRepoResolver(environment: ctx.environment).resolve(cwd: ctx.cwd);
      ctx.console.ok('skills repo', repo.path);
    } on HippoException catch (error) {
      ctx.console.warn('skills repo', error.message);
    }
  }
}

final class SelfCommand extends HippoCommand {
  SelfCommand(super.contextFactory) {
    addSubcommand(SelfVersionCommand(contextFactory));
  }

  @override
  String get name => 'self';

  @override
  String get description => 'Inspect or manage the Hippo executable.';
}

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

final class WorkspaceCommand extends HippoCommand {
  WorkspaceCommand(super.contextFactory) {
    addSubcommand(WorkspaceCheckCommand(contextFactory));
  }

  @override
  String get name => 'workspace';

  @override
  String get description => 'Inspect and validate the current workspace.';
}

final class CheckCommand extends HippoCommand {
  CheckCommand(super.contextFactory);

  @override
  String get name => 'check';

  @override
  String get description => 'Alias for workspace check.';

  @override
  Future<int> run() => WorkspaceCheckCommand(contextFactory).run();
}

final class WorkspaceCheckCommand extends HippoCommand {
  WorkspaceCheckCommand(super.contextFactory);

  @override
  String get name => 'check';

  @override
  String get description => 'Check that the current workspace is recognizable.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final workspace = await const WorkspaceDetector().detect(ctx.cwd);
    if (workspace.type == HippoWorkspaceType.unknown) {
      throw HippoException(
        'Unknown workspace.',
        expected: 'Expected a Dart pub workspace, Dart package, or Hipposphere skills repo.',
        exitCode: HippoExitCode.config,
      );
    }
    ctx.console.ok('workspace', workspace.description);
    ctx.console.info('root', workspace.root.path);
    return HippoExitCode.ok;
  }
}

final class ReleaseCommand extends HippoCommand {
  ReleaseCommand(super.contextFactory) {
    addSubcommand(ReleaseVersionCommand(contextFactory));
    addSubcommand(ReleaseDockerCommand(contextFactory));
    addSubcommand(ReleaseFlutterCommand(contextFactory));
  }

  @override
  String get name => 'release';

  @override
  String get description => 'Build and release Hipposphere artifacts.';
}

final class ReleaseVersionCommand extends HippoCommand {
  ReleaseVersionCommand(super.contextFactory) {
    argParser
      ..addFlag('json', negatable: false, help: 'Print JSON output.')
      ..addFlag('github-output', negatable: false, help: 'Append values to GITHUB_OUTPUT.');
  }

  @override
  String get name => 'version';

  @override
  String get description => 'Read a package version from pubspec.yaml.';

  @override
  String get invocation => 'hippo release version [--json] [--github-output] <package-path>';

  @override
  Future<int> run() async {
    final ctx = await context;
    if (argResults!.rest.length != 1) {
      usageException('Expected exactly one package path.');
    }
    final packagePath = argResults!.rest.single;
    final output = await PackageVersionOutput.read(
      Directory(p.isAbsolute(packagePath) ? packagePath : p.join(ctx.cwd.path, packagePath)),
    );
    if (argResults!.flag('github-output')) {
      final githubOutput = ctx.environment['GITHUB_OUTPUT'];
      if (githubOutput == null || githubOutput.isEmpty) {
        usageException('GITHUB_OUTPUT is not set.');
      }
      await File(githubOutput).writeAsString(output.toEnv(), mode: FileMode.append);
    }
    ctx.console.write(argResults!.flag('json') || ctx.json ? output.toJson() : output.toEnv());
    return HippoExitCode.ok;
  }
}

final class ReleaseDockerCommand extends HippoCommand {
  ReleaseDockerCommand(super.contextFactory) {
    addSubcommand(DockerGenerateCommand(contextFactory));
    addSubcommand(DockerBuildCommand(contextFactory));
    addSubcommand(DockerBakeCommand(contextFactory));
    addSubcommand(DockerPrintConfigCommand(contextFactory));
  }

  @override
  String get name => 'docker';

  @override
  String get description => 'Generate and build Docker artifacts.';
}

final class DockerGenerateCommand extends HippoCommand {
  DockerGenerateCommand(super.contextFactory) {
    argParser
      ..addOption('config', defaultsTo: 'docker.yaml', help: 'Path to docker.yaml.')
      ..addFlag(
        'github-output',
        negatable: false,
        help: 'Append generated paths to GITHUB_OUTPUT.',
      );
  }

  @override
  String get name => 'generate';

  @override
  String get description => 'Generate Dockerfiles and Docker Bake targets.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final selectedImage = argResults!.rest.singleOrNull;
    if (argResults!.rest.length > 1) {
      usageException('Expected at most one image name.');
    }
    final result = await ctx.console
        .spinner('Generating Docker artifacts')
        .during(
          () => DockerGenerator(
            projectRoot: ctx.cwd,
          ).generate(configPath: argResults!.option('config')!, selectedImage: selectedImage),
        );
    for (final image in result.images) {
      ctx.console.ok('generated ${image.name}', image.dockerfile.path);
    }
    ctx.console.ok('bake file', result.bakeFile.path);
    if (argResults!.flag('github-output')) {
      final githubOutput = ctx.environment['GITHUB_OUTPUT'];
      if (githubOutput == null || githubOutput.isEmpty) {
        usageException('GITHUB_OUTPUT is not set.');
      }
      if (result.images.length != 1) {
        usageException('Expected exactly one selected image when using --github-output.');
      }
      final image = result.images.single;
      await File(githubOutput).writeAsString(
        'image=${image.name}\ndockerfile=${image.dockerfile.path}\ncontext=${image.context.path}\n',
        mode: FileMode.append,
      );
    }
    return HippoExitCode.ok;
  }
}

final class DockerBuildCommand extends HippoCommand {
  DockerBuildCommand(super.contextFactory) {
    argParser
      ..addOption('config', defaultsTo: 'docker.yaml', help: 'Path to docker.yaml.')
      ..addFlag('push', negatable: false, help: 'Pass --push to docker buildx build.');
  }

  @override
  String get name => 'build';

  @override
  String get description => 'Generate and run docker buildx build.';

  @override
  Future<int> run() async {
    final ctx = await context;
    if (argResults!.rest.length != 1) {
      usageException('Expected exactly one image name.');
    }
    final imageName = argResults!.rest.single;
    return DockerGenerator(projectRoot: ctx.cwd).build(
      imageName: imageName,
      configPath: argResults!.option('config')!,
      push: argResults!.flag('push'),
      processRunner: ctx.processRunner,
    );
  }
}

final class DockerBakeCommand extends HippoCommand {
  DockerBakeCommand(super.contextFactory) {
    argParser.addOption('config', defaultsTo: 'docker.yaml', help: 'Path to docker.yaml.');
  }

  @override
  String get name => 'bake';

  @override
  String get description => 'Generate and print the Docker Bake file path.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final result = await DockerGenerator(
      projectRoot: ctx.cwd,
    ).generate(configPath: argResults!.option('config')!);
    ctx.console.writeln(result.bakeFile.path);
    return HippoExitCode.ok;
  }
}

final class DockerPrintConfigCommand extends HippoCommand {
  DockerPrintConfigCommand(super.contextFactory) {
    argParser.addOption('config', defaultsTo: 'docker.yaml', help: 'Path to docker.yaml.');
  }

  @override
  String get name => 'print-config';

  @override
  String get description => 'Print the normalized docker.yaml model.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final config = await DockerGenerator(
      projectRoot: ctx.cwd,
    ).loadConfig(path: argResults!.option('config')!);
    ctx.console.writeln(config.toPrettyJson());
    return HippoExitCode.ok;
  }
}

final class ReleaseFlutterCommand extends HippoCommand {
  ReleaseFlutterCommand(super.contextFactory) {
    addSubcommand(FlutterBuildCommand(contextFactory));
    addSubcommand(FlutterPublishCommand(contextFactory));
    addSubcommand(FlutterSigningCommand(contextFactory));
    addSubcommand(FlutterArtifactPathsCommand(contextFactory));
    addSubcommand(FlutterPrintConfigCommand(contextFactory));
  }

  @override
  String get name => 'flutter';

  @override
  String get description => 'Build and publish Flutter release artifacts.';
}

final class FlutterBuildCommand extends HippoCommand {
  FlutterBuildCommand(super.contextFactory) {
    argParser
      ..addOption('config', defaultsTo: 'flutter_release.yaml', help: 'Path to release config.')
      ..addFlag('all', negatable: false, help: 'Build every enabled target.')
      ..addFlag('dry-run', negatable: false, help: 'Print commands without executing them.')
      ..addFlag('github-output', negatable: false, help: 'Append artifact paths to GITHUB_OUTPUT.');
  }

  @override
  String get name => 'build';

  @override
  String get description => 'Run flutter build for configured targets.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final builder = FlutterReleaseBuilder(projectRoot: ctx.cwd, processRunner: ctx.processRunner);
    final config = await builder.loadConfig(path: argResults!.option('config')!);
    final targets = _selectedFlutterTargets(config, argResults!);
    for (final target in targets) {
      final exitCode = await builder.build(
        target,
        config: config,
        dryRun: argResults!.flag('dry-run'),
      );
      if (exitCode != 0) {
        return exitCode;
      }
    }
    if (argResults!.flag('github-output')) {
      await _writeFlutterGithubOutput(ctx, config, targets);
    }
    return HippoExitCode.ok;
  }
}

final class FlutterPublishCommand extends HippoCommand {
  FlutterPublishCommand(super.contextFactory) {
    addSubcommand(FlutterPublishIosAppStoreCommand(contextFactory));
  }

  @override
  String get name => 'publish';

  @override
  String get description => 'Publish Flutter release artifacts.';
}

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

final class FlutterSigningCommand extends HippoCommand {
  FlutterSigningCommand(super.contextFactory) {
    addSubcommand(FlutterSigningIosCommand(contextFactory));
  }

  @override
  String get name => 'signing';

  @override
  String get description => 'Install Flutter signing material.';
}

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

final class FlutterArtifactPathsCommand extends HippoCommand {
  FlutterArtifactPathsCommand(super.contextFactory) {
    argParser.addOption(
      'config',
      defaultsTo: 'flutter_release.yaml',
      help: 'Path to release config.',
    );
  }

  @override
  String get name => 'artifact-paths';

  @override
  String get description => 'Print default artifact upload paths.';

  @override
  Future<int> run() async {
    final ctx = await context;
    if (argResults!.rest.length != 1) {
      usageException('Expected exactly one target.');
    }
    final builder = FlutterReleaseBuilder(projectRoot: ctx.cwd);
    final config = await builder.loadConfig(path: argResults!.option('config')!);
    ctx.console.writeln(artifactPaths(config, argResults!.rest.single).join('\n'));
    return HippoExitCode.ok;
  }
}

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

final class SkillsCommand extends HippoCommand {
  SkillsCommand(super.contextFactory) {
    addSubcommand(SkillsInstallCommand(contextFactory));
    addSubcommand(SkillsUpdateCommand(contextFactory));
    addSubcommand(SkillsUninstallCommand(contextFactory));
    addSubcommand(SkillsListCommand(contextFactory));
    addSubcommand(SkillsValidateCommand(contextFactory));
    addSubcommand(SkillsDoctorCommand(contextFactory));
  }

  @override
  String get name => 'skills';

  @override
  String get description => 'Install and validate Hipposphere agent skills.';
}

abstract base class SkillsMutatingCommand extends HippoCommand {
  SkillsMutatingCommand(super.contextFactory) {
    argParser
      ..addOption('repo', help: 'Path to the Hipposphere skills repo.')
      ..addFlag('codex', defaultsTo: true, help: 'Target Codex skills.')
      ..addFlag('claude', defaultsTo: true, help: 'Target Claude Code skills.');
  }

  Future<SkillsInstallOptions> options({
    required bool updateRepo,
    required bool requireUpdate,
  }) async {
    final ctx = await context;
    final repo = SkillsRepoResolver(
      environment: ctx.environment,
    ).resolve(explicitPath: argResults!.option('repo'), cwd: ctx.cwd);
    final targets = defaultTargets(
      environment: ctx.environment,
      codex: argResults!.flag('codex'),
      claude: argResults!.flag('claude'),
    );
    if (targets.isEmpty) {
      usageException('No skill targets selected.');
    }
    return SkillsInstallOptions(
      repoRoot: repo,
      targets: targets,
      updateRepo: updateRepo,
      requireUpdate: requireUpdate,
    );
  }
}

final class SkillsInstallCommand extends SkillsMutatingCommand {
  SkillsInstallCommand(super.contextFactory) {
    argParser.addFlag(
      'update',
      defaultsTo: false,
      help: 'Run git pull --ff-only before installing.',
    );
  }

  @override
  String get name => 'install';

  @override
  String get description => 'Install Hipposphere skills.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final installOptions = await options(
      updateRepo: argResults!.flag('update'),
      requireUpdate: argResults!.flag('update'),
    );
    await ctx.console
        .spinner('Installing skills')
        .during(() => SkillsInstaller(processRunner: ctx.processRunner).install(installOptions));
    for (final target in installOptions.targets) {
      ctx.console.ok('skills installed', target.name);
    }
    return HippoExitCode.ok;
  }
}

final class SkillsUpdateCommand extends SkillsMutatingCommand {
  SkillsUpdateCommand(super.contextFactory);

  @override
  String get name => 'update';

  @override
  String get description => 'Update the skills repo and install skills.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final installOptions = await options(updateRepo: true, requireUpdate: true);
    await ctx.console
        .spinner('Updating skills')
        .during(() => SkillsInstaller(processRunner: ctx.processRunner).install(installOptions));
    for (final target in installOptions.targets) {
      ctx.console.ok('skills updated', target.name);
    }
    return HippoExitCode.ok;
  }
}

final class SkillsUninstallCommand extends SkillsMutatingCommand {
  SkillsUninstallCommand(super.contextFactory);

  @override
  String get name => 'uninstall';

  @override
  String get description => 'Uninstall Hipposphere skills.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final installOptions = await options(updateRepo: false, requireUpdate: false);
    await SkillsInstaller(processRunner: ctx.processRunner).uninstall(installOptions);
    for (final target in installOptions.targets) {
      ctx.console.ok('skills uninstalled', target.name);
    }
    return HippoExitCode.ok;
  }
}

final class SkillsListCommand extends HippoCommand {
  SkillsListCommand(super.contextFactory) {
    argParser.addOption('repo', help: 'Path to the Hipposphere skills repo.');
  }

  @override
  String get name => 'list';

  @override
  String get description => 'List available Hipposphere skills.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final repo = SkillsRepoResolver(
      environment: ctx.environment,
    ).resolve(explicitPath: argResults!.option('repo'), cwd: ctx.cwd);
    final rows = [
      for (final dir in resolveSkillDirs(repo, const [])) [p.basename(dir.path), dir.path],
    ];
    ctx.console.table(HippoTable(headers: const ['Skill', 'Path'], rows: rows));
    return HippoExitCode.ok;
  }
}

final class SkillsValidateCommand extends HippoCommand {
  SkillsValidateCommand(super.contextFactory) {
    argParser.addOption('repo', help: 'Path to the Hipposphere skills repo.');
  }

  @override
  String get name => 'validate';

  @override
  String get description => 'Validate skill metadata and references.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final repo = SkillsRepoResolver(
      environment: ctx.environment,
    ).resolve(explicitPath: argResults!.option('repo'), cwd: ctx.cwd);
    final validator = const SkillsValidator();
    var failed = false;
    for (final dir in resolveSkillDirs(repo, argResults!.rest)) {
      final result = validator.validate(dir);
      if (result.success) {
        ctx.console.ok(p.relative(dir.path, from: repo.path));
      } else {
        failed = true;
        ctx.console.fail(p.relative(dir.path, from: repo.path));
        for (final error in result.errors) {
          ctx.console.stderrLine('  - $error');
        }
      }
    }
    return failed ? HippoExitCode.config : HippoExitCode.ok;
  }
}

final class SkillsDoctorCommand extends HippoCommand {
  SkillsDoctorCommand(super.contextFactory) {
    argParser.addOption('repo', help: 'Path to the Hipposphere skills repo.');
  }

  @override
  String get name => 'doctor';

  @override
  String get description => 'Check skills repo and install targets.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final repo = SkillsRepoResolver(
      environment: ctx.environment,
    ).resolve(explicitPath: argResults!.option('repo'), cwd: ctx.cwd);
    ctx.console.ok('skills repo', repo.path);
    final targets = defaultTargets(environment: ctx.environment, codex: true, claude: true);
    for (final target in targets) {
      ctx.console.info(target.name, target.directory.path);
    }
    return HippoExitCode.ok;
  }
}

final class TestCommand extends HippoCommand {
  TestCommand(super.contextFactory) {
    addSubcommand(RunSuiteCommand(contextFactory, name: 'routes'));
    addSubcommand(RunSuiteCommand(contextFactory, name: 'e2e'));
    addSubcommand(TestEnvCommand(contextFactory));
  }

  @override
  String get name => 'test';

  @override
  String get description => 'Run route, e2e, and environment tests.';
}

final class RunSuiteCommand extends HippoCommand {
  RunSuiteCommand(super.contextFactory, {required this.name}) {
    argParser
      ..addOption(
        'suite',
        defaultsTo: 'packages/dart_edge_test_suite',
        help: 'Test suite package path.',
      )
      ..addOption('path', defaultsTo: 'test/$name', help: 'Path inside suite package.')
      ..addOption('base-url', help: 'Base URL exposed as TEST_BASE_URL.')
      ..addOption('compose-file', help: 'Docker Compose file to start before tests.')
      ..addOption('compose-project-name', help: 'Docker Compose project name.')
      ..addFlag('compose-down', defaultsTo: true, help: 'Run docker compose down after tests.')
      ..addOption('health-url', help: 'Health URL to poll before tests.')
      ..addOption('health-timeout', defaultsTo: '90', help: 'Health timeout in seconds.')
      ..addOption('reporter', defaultsTo: 'expanded', help: 'dart test reporter.')
      ..addOption('dart', defaultsTo: 'dart', help: 'Dart executable.');
  }

  @override
  final String name;

  @override
  String get description => 'Run the $name test suite.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final baseUrl = argResults!.option('base-url');
    final healthUrl = argResults!.option('health-url') ?? baseUrl;
    return TestSuiteRunner(processRunner: ctx.processRunner).run(
      TestSuiteConfig(
        projectRoot: ctx.cwd,
        suitePath: argResults!.option('suite')!,
        testPath: argResults!.option('path')!,
        environment: baseUrl == null ? const {} : {'TEST_BASE_URL': baseUrl},
        extraTestArguments: argResults!.rest,
        reporter: argResults!.option('reporter')!,
        composeFile: argResults!.option('compose-file'),
        composeProjectName: argResults!.option('compose-project-name'),
        composeDown: argResults!.flag('compose-down'),
        healthUrl: healthUrl == null ? null : Uri.parse(healthUrl),
        healthTimeout: Duration(seconds: int.parse(argResults!.option('health-timeout')!)),
        dartExecutable: argResults!.option('dart')!,
      ),
    );
  }
}

final class TestEnvCommand extends HippoCommand {
  TestEnvCommand(super.contextFactory) {
    addSubcommand(ComposeCommand(contextFactory, name: 'up'));
    addSubcommand(ComposeCommand(contextFactory, name: 'down'));
  }

  @override
  String get name => 'env';

  @override
  String get description => 'Manage Docker Compose test environments.';
}

final class ComposeCommand extends HippoCommand {
  ComposeCommand(super.contextFactory, {required this.name}) {
    argParser
      ..addOption(
        'compose-file',
        defaultsTo: 'environment/compose.yaml',
        help: 'Docker Compose file.',
      )
      ..addOption('compose-project-name', help: 'Docker Compose project name.');
  }

  @override
  final String name;

  @override
  String get description =>
      name == 'up' ? 'Start the test environment.' : 'Stop the test environment.';

  @override
  Future<int> run() async {
    final ctx = await context;
    return TestSuiteRunner(processRunner: ctx.processRunner).compose(
      projectRoot: ctx.cwd,
      action: name == 'up' ? ComposeAction.up : ComposeAction.down,
      composeFile: argResults!.option('compose-file')!,
      composeProjectName: argResults!.option('compose-project-name'),
    );
  }
}

final class BenchCommand extends HippoCommand {
  BenchCommand(super.contextFactory) {
    addSubcommand(ServerBenchCommand(contextFactory));
  }

  @override
  String get name => 'bench';

  @override
  String get description => 'Run reproducible benchmark suites.';
}

final class ServerBenchCommand extends HippoCommand {
  ServerBenchCommand(super.contextFactory) {
    argParser
      ..addOption('url', mandatory: true, help: 'HTTP endpoint to benchmark.')
      ..addOption('method', defaultsTo: 'GET', help: 'HTTP method.')
      ..addMultiOption('header', help: 'HTTP header in "Name: value" format.')
      ..addOption('duration', defaultsTo: '30', help: 'Benchmark duration in seconds.')
      ..addOption('warmup', defaultsTo: '5', help: 'Warmup duration in seconds.')
      ..addOption('concurrency', defaultsTo: '16', help: 'Concurrent request loops.')
      ..addOption(
        'output',
        defaultsTo: 'build/reports/bench/server.json',
        help: 'JSON report path.',
      )
      ..addOption('max-p95-latency-ms', help: 'Fail if p95 latency exceeds this threshold.')
      ..addOption('min-throughput', help: 'Fail if throughput is below this req/s threshold.');
  }

  @override
  String get name => 'server';

  @override
  String get description => 'Benchmark a server HTTP endpoint.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final result = await ServerBenchmarkRunner().run(
      ServerBenchmarkConfig(
        url: Uri.parse(argResults!.option('url')!),
        method: argResults!.option('method')!,
        headers: _parseHeaders(argResults!.multiOption('header')),
        duration: Duration(seconds: int.parse(argResults!.option('duration')!)),
        warmup: Duration(seconds: int.parse(argResults!.option('warmup')!)),
        concurrency: int.parse(argResults!.option('concurrency')!),
        outputPath: argResults!.option('output')!,
        maxP95LatencyMs: _tryParseDouble(argResults!.option('max-p95-latency-ms')),
        minThroughput: _tryParseDouble(argResults!.option('min-throughput')),
      ),
    );
    ctx.console.ok('benchmark', '${result.throughput.toStringAsFixed(1)} req/s');
    return HippoExitCode.ok;
  }
}

List<String> _selectedFlutterTargets(FlutterReleaseConfig config, ArgResults results) {
  if (results.flag('all')) {
    if (results.rest.isNotEmpty) {
      throw UsageException('Do not pass a target when using --all.', '');
    }
    return [
      for (final entry in config.targets.entries)
        if (entry.value.enabled) entry.key,
    ];
  }
  if (results.rest.length != 1) {
    throw UsageException('Expected exactly one target, or pass --all.', '');
  }
  return [results.rest.single];
}

Future<void> _writeFlutterGithubOutput(
  HippoCommandContext ctx,
  FlutterReleaseConfig config,
  List<String> targets,
) async {
  final githubOutput = ctx.environment['GITHUB_OUTPUT'];
  if (githubOutput == null || githubOutput.isEmpty) {
    throw const HippoException('GITHUB_OUTPUT is not set.', exitCode: HippoExitCode.usage);
  }
  final buffer = StringBuffer();
  if (targets.length == 1) {
    final targetName = targets.single;
    final target = config.target(targetName);
    buffer
      ..writeln('target=$targetName')
      ..writeln('platform=${target.platform.name}')
      ..writeln('artifact_path=${artifactPaths(config, targetName).join(',')}');
  } else {
    buffer.writeln('artifact_paths<<hippo');
    for (final targetName in targets) {
      for (final path in artifactPaths(config, targetName)) {
        buffer.writeln(path);
      }
    }
    buffer.writeln('hippo');
  }
  await File(githubOutput).writeAsString(buffer.toString(), mode: FileMode.append);
}

Map<String, String> _parseHeaders(List<String> values) {
  final headers = <String, String>{};
  for (final value in values) {
    final separator = value.indexOf(':');
    if (separator <= 0) {
      throw UsageException('Expected --header values in "Name: value" format.', '');
    }
    headers[value.substring(0, separator).trim()] = value.substring(separator + 1).trim();
  }
  return headers;
}

double? _tryParseDouble(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return double.parse(value);
}

String _firstLine(String text) {
  return text.trim().split('\n').firstOrNull ?? '';
}

extension<T> on List<T> {
  T? get singleOrNull => length == 1 ? single : null;
  T? get firstOrNull => isEmpty ? null : first;
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
