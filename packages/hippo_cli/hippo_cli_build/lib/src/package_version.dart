import 'dart:convert';
import 'dart:io';

import 'package:hippo_cli_core/hippo_cli_core.dart';
import 'package:yaml/yaml.dart';

final class PackageVersionOutput {
  const PackageVersionOutput({required this.version, required this.versionTag});

  final String version;
  final String versionTag;

  static Future<PackageVersionOutput> read(Directory packageRoot) async {
    final pubspec = File('${packageRoot.path}/pubspec.yaml');
    if (!await pubspec.exists()) {
      throw HippoException(
        'Could not find pubspec.yaml.',
        expected: 'Expected a Dart package at ${packageRoot.path}.',
        exitCode: HippoExitCode.config,
      );
    }
    final document = loadYaml(await pubspec.readAsString());
    if (document is! YamlMap || document['version'] is! String) {
      throw const HippoException(
        'Could not read package version.',
        expected: 'Expected pubspec.yaml to contain a string version.',
        exitCode: HippoExitCode.config,
      );
    }
    final version = document['version'] as String;
    return PackageVersionOutput(version: version, versionTag: version.replaceAll('+', '-'));
  }

  Map<String, String> toMap() => {'version': version, 'version_tag': versionTag};

  String toEnv() {
    final buffer = StringBuffer();
    for (final entry in toMap().entries) {
      buffer.writeln('${entry.key}=${entry.value}');
    }
    return buffer.toString();
  }

  String toJson() => jsonEncode(toMap());
}
