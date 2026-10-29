import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:test/test.dart';

void main() {
  test('both presets report structural violations and accept ordered code', () async {
    final packageConfigUri = (await Isolate.packageConfig)!;
    final packageConfig =
        jsonDecode(await File.fromUri(packageConfigUri).readAsString()) as Map<String, dynamic>;
    for (final package in packageConfig['packages'] as List<dynamic>) {
      final entry = package as Map<String, dynamic>;
      entry['rootUri'] = packageConfigUri.resolve(entry['rootUri'] as String).toString();
    }

    final fixture = await Directory.systemTemp.createTemp('hippo_analysis_structure_');
    addTearDown(() => fixture.delete(recursive: true));
    await Directory('${fixture.path}/.dart_tool').create();
    await File('${fixture.path}/.dart_tool/package_config.json')
        .writeAsString(jsonEncode(packageConfig));

    for (final preset in ['dart', 'flutter']) {
      final pluginUri = (await Isolate.resolvePackageUri(
        .parse('package:hippo_analysis_plugin/main.dart'),
      ))!;
      final pluginPath = File.fromUri(pluginUri).parent.parent.path;
      final presetUri = (await Isolate.resolvePackageUri(
        .parse('package:hippo_analysis/$preset.yaml'),
      ))!;
      await File('${fixture.path}/analysis_options.yaml').writeAsString('''
include: ${presetUri.toFilePath()}
plugins:
  dependency_overrides:
    hippo_analysis_plugin:
      path: $pluginPath
''');
      final pubspec = File('${fixture.path}/pubspec.yaml');
      final source = File('${fixture.path}/example.dart');
      await pubspec.writeAsString('''
name: structure_fixture
environment:
  sdk: '>=3.13.0 <4.0.0'
dev_dependencies:
  test: any
  dart_style: any
''');
      await source.writeAsString('''
import 'dart:math';
import 'dart:async';

Future<double> calculate() => Future<double>.value(sqrt(4));

enum Mode { active }
Mode get mode => Mode.active;

class Example {
  final int value;

  const Example.named({required this.value});
  const Example({bool enabled = false, required this.value});
}
''');

      final unordered = await Process.run(Platform.resolvedExecutable, [
        'analyze',
        '--fatal-infos',
        '--format=machine',
        '.',
      ], workingDirectory: fixture.path);
      final diagnostics = '${unordered.stdout}\n${unordered.stderr}';
      expect(unordered.exitCode, isNot(0), reason: '$preset: $diagnostics');
      expect(diagnostics, isNot(contains('ERROR|')), reason: '$preset: $diagnostics');
      for (final rule in [
        'always_put_required_named_parameters_first',
        'directives_ordering',
        'sort_constructors_first',
        'sort_pub_dependencies',
        'sort_unnamed_constructors_first',
        'prefer_dot_shorthands',
      ]) {
        final codes = diagnostics
            .split('\n')
            .where((line) => line.startsWith('INFO|'))
            .map((line) => line.split('|')[2].toLowerCase().split('/').last);
        expect(codes, contains(rule), reason: '$preset: $diagnostics');
      }

      await pubspec.writeAsString('''
name: structure_fixture
environment:
  sdk: '>=3.13.0 <4.0.0'
dev_dependencies:
  dart_style: any
  test: any
''');
      await source.writeAsString('''
import 'dart:async';
import 'dart:math';

Future<double> calculate() => Future<double>.value(sqrt(4));

enum Mode { active }
Mode get mode => .active;

class Example {
  const Example({required this.value, bool enabled = false});
  const Example.named({required this.value});

  final int value;
}
''');

      final ordered = await Process.run(Platform.resolvedExecutable, [
        'analyze',
        '--fatal-infos',
        '--format=machine',
        '.',
      ], workingDirectory: fixture.path);
      expect(ordered.exitCode, 0, reason: '$preset: ${ordered.stdout}\n${ordered.stderr}');
    }
  }, timeout: const .new(.new(minutes: 3)));
}
