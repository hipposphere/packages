import 'dart:convert';
import 'dart:io';

import 'package:hippo_cli_core/hippo_cli_core.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

enum FlutterReleasePlatform { android, ios, macos, windows, linux, web }

final class FlutterReleaseConfig {
  const FlutterReleaseConfig({required this.variables, required this.targets});

  final Map<String, String> variables;
  final Map<String, FlutterReleaseTarget> targets;

  static FlutterReleaseConfig parse(String yamlText) {
    final document = loadYaml(yamlText);
    if (document is! YamlMap) {
      throw const HippoException(
        'Invalid flutter_release.yaml.',
        expected: 'Expected a YAML map.',
        exitCode: HippoExitCode.config,
      );
    }
    final targetsYaml = document['targets'];
    if (targetsYaml is! YamlMap || targetsYaml.isEmpty) {
      throw const HippoException(
        'Invalid flutter_release.yaml.',
        expected: 'Expected a targets map.',
        exitCode: HippoExitCode.config,
      );
    }
    final variables = _stringMap(document['variables']);
    return FlutterReleaseConfig(
      variables: variables,
      targets: {
        for (final entry in targetsYaml.entries)
          if (entry.key is String)
            entry.key as String: FlutterReleaseTarget.parse(
              entry.key as String,
              entry.value,
              variables,
            ),
      },
    );
  }

  FlutterReleaseTarget target(String name) {
    return targets[name] ??
        (throw HippoException(
          'Unknown Flutter release target "$name".',
          expected: 'Expected one of: ${targets.keys.join(', ')}.',
          exitCode: HippoExitCode.usage,
        ));
  }

  Map<String, Object?> toJsonMap() => {
    'variables': variables,
    'targets': {for (final entry in targets.entries) entry.key: entry.value.toJsonMap()},
  };

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJsonMap());
}

final class FlutterReleaseTarget {
  const FlutterReleaseTarget({
    required this.name,
    required this.platform,
    required this.packagePath,
    required this.enabled,
    required this.dartDefines,
    required this.buildArgs,
    required this.artifactPaths,
  });

  final String name;
  final FlutterReleasePlatform platform;
  final String packagePath;
  final bool enabled;
  final Map<String, String> dartDefines;
  final List<String> buildArgs;
  final List<String> artifactPaths;

  static FlutterReleaseTarget parse(String name, Object? value, Map<String, String> variables) {
    if (value is! YamlMap) {
      throw HippoException(
        'Invalid Flutter release target "$name".',
        expected: 'Expected target configuration to be a YAML map.',
        exitCode: HippoExitCode.config,
      );
    }
    final platformName = value['platform'];
    if (platformName is! String) {
      throw HippoException(
        'Invalid Flutter release target "$name".',
        expected: 'Expected platform to be a string.',
        exitCode: HippoExitCode.config,
      );
    }
    final platform = FlutterReleasePlatform.values.firstWhere(
      (candidate) => candidate.name == platformName,
      orElse: () => throw HippoException(
        'Unsupported Flutter platform "$platformName".',
        expected:
            'Expected one of: ${FlutterReleasePlatform.values.map((v) => v.name).join(', ')}.',
        exitCode: HippoExitCode.config,
      ),
    );
    return FlutterReleaseTarget(
      name: name,
      platform: platform,
      packagePath: _optionalString(value['package']) ?? '.',
      enabled: value['enabled'] != false,
      dartDefines: {
        for (final entry in _stringMap(value['dart_defines']).entries)
          entry.key: _expandVariables(entry.value, variables),
      },
      buildArgs: _stringList(value['build_args']),
      artifactPaths: _stringList(value['artifact_paths']),
    );
  }

  Map<String, Object?> toJsonMap() => {
    'platform': platform.name,
    'package': packagePath,
    'enabled': enabled,
    'dart_defines': dartDefines,
    'build_args': buildArgs,
    'artifact_paths': artifactPaths,
  };
}

final class FlutterReleaseBuilder {
  const FlutterReleaseBuilder({
    required this.projectRoot,
    this.processRunner = const HippoProcessRunner(),
  });

  final Directory projectRoot;
  final HippoProcessRunner processRunner;

  Future<FlutterReleaseConfig> loadConfig({String path = 'flutter_release.yaml'}) async {
    final file = File(p.isAbsolute(path) ? path : p.join(projectRoot.path, path));
    if (!await file.exists()) {
      throw HippoException(
        'Could not find flutter_release.yaml.',
        expected: 'Expected a Flutter release config at ${file.path}.',
        nextSteps: const ['Create flutter_release.yaml or pass --config <path>.'],
        exitCode: HippoExitCode.config,
      );
    }
    return FlutterReleaseConfig.parse(await file.readAsString());
  }

  Future<int> build(
    String targetName, {
    required FlutterReleaseConfig config,
    bool dryRun = false,
  }) {
    final target = config.target(targetName);
    final command = flutterBuildCommand(target);
    if (dryRun) {
      stdout.writeln(shellCommand(command));
      return Future.value(0);
    }
    return processRunner.inherit(
      command.first,
      command.skip(1).toList(),
      workingDirectory: p.join(projectRoot.path, target.packagePath),
    );
  }

  Future<int> publishIosAppStore({
    required String targetName,
    required FlutterReleaseConfig config,
    bool dryRun = false,
  }) async {
    final target = config.target(targetName);
    final ipa = artifactPaths(
      config,
      targetName,
    ).firstWhere((path) => path.endsWith('.ipa'), orElse: () => 'build/ios/ipa/*.ipa');
    final command = ['xcrun', 'altool', '--upload-app', '--type', 'ios', '--file', ipa];
    if (dryRun) {
      stdout.writeln(shellCommand(command));
      return 0;
    }
    return processRunner.inherit(
      command.first,
      command.skip(1).toList(),
      workingDirectory: p.join(projectRoot.path, target.packagePath),
    );
  }

  Future<int> installIosSigningMaterial({
    required String? targetName,
    required FlutterReleaseConfig config,
    bool dryRun = false,
  }) async {
    config.target(targetName ?? config.targets.keys.first);
    if (dryRun) {
      stdout.writeln('Validate iOS signing material');
    }
    return 0;
  }
}

List<String> flutterBuildCommand(FlutterReleaseTarget target) {
  return [
    'flutter',
    'build',
    target.platform == FlutterReleasePlatform.ios ? 'ipa' : target.platform.name,
    '--release',
    for (final entry in target.dartDefines.entries) '--dart-define=${entry.key}=${entry.value}',
    ...target.buildArgs,
  ];
}

List<String> artifactPaths(FlutterReleaseConfig config, String targetName) {
  final target = config.target(targetName);
  if (target.artifactPaths.isNotEmpty) {
    return target.artifactPaths;
  }
  return switch (target.platform) {
    FlutterReleasePlatform.android => ['${target.packagePath}/build/app/outputs/**/*.aab'],
    FlutterReleasePlatform.ios => ['${target.packagePath}/build/ios/ipa/*.ipa'],
    FlutterReleasePlatform.macos => [
      '${target.packagePath}/build/macos/Build/Products/Release/*.app',
    ],
    FlutterReleasePlatform.windows => ['${target.packagePath}/build/windows/x64/runner/Release'],
    FlutterReleasePlatform.linux => ['${target.packagePath}/build/linux/x64/release/bundle'],
    FlutterReleasePlatform.web => ['${target.packagePath}/build/web'],
  };
}

Map<String, String> _stringMap(Object? value) {
  if (value is! YamlMap) {
    return const {};
  }
  return {
    for (final entry in value.entries)
      if (entry.key is String && entry.value != null) entry.key as String: entry.value.toString(),
  };
}

List<String> _stringList(Object? value) {
  if (value is! YamlList) {
    return const [];
  }
  return [for (final item in value) item.toString()];
}

String? _optionalString(Object? value) => value is String && value.isNotEmpty ? value : null;

String _expandVariables(String value, Map<String, String> variables) {
  var result = value;
  for (final entry in variables.entries) {
    result = result.replaceAll(
      r'${'
      '${entry.key}'
      '}',
      entry.value,
    );
  }
  return result;
}
