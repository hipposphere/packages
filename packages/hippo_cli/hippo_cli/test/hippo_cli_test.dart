import 'dart:io';

import 'package:hippo_cli/hippo_cli.dart';
import 'package:test/test.dart';

void main() {
  test('prints top-level help', () async {
    final out = StringBuffer();

    final exitCode = await runHippo(['--help'], stdoutSink: out, stdoutIsTerminal: false);

    expect(exitCode, 0);
    expect(out.toString(), contains('Hipposphere developer tooling.'));
    expect(out.toString(), contains('doctor'));
  });

  test('prints self version', () async {
    final out = StringBuffer();

    final exitCode = await runHippo(['self', 'version'], stdoutSink: out, stdoutIsTerminal: false);

    expect(exitCode, 0);
    expect(out.toString().trim(), '0.1.0');
  });

  test('release version works from package path', () async {
    final dir = await Directory.systemTemp.createTemp('hippo_cli_version_');
    addTearDown(() => dir.delete(recursive: true));
    await File('${dir.path}/pubspec.yaml').writeAsString('''
name: sample
version: 0.2.0
''');
    final out = StringBuffer();

    final exitCode = await runHippo(
      ['release', 'version', dir.path],
      stdoutSink: out,
      stdoutIsTerminal: false,
    );

    expect(exitCode, 0);
    expect(out.toString(), contains('version=0.2.0'));
  });
}
