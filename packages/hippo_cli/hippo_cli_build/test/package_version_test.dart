import 'dart:io';

import 'package:hippo_cli_build/hippo_cli_build.dart';
import 'package:test/test.dart';

void main() {
  test('reads version and tag from pubspec', () async {
    final dir = await Directory.systemTemp.createTemp('hippo_package_');
    addTearDown(() => dir.delete(recursive: true));
    await File('${dir.path}/pubspec.yaml').writeAsString('''
name: sample
version: 1.2.3+4
''');

    final output = await PackageVersionOutput.read(dir);

    expect(output.version, '1.2.3+4');
    expect(output.versionTag, '1.2.3-4');
    expect(output.toEnv(), contains('version=1.2.3+4'));
  });
}
