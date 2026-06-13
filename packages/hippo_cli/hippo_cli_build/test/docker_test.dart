import 'dart:io';

import 'package:hippo_cli_build/hippo_cli_build.dart';
import 'package:test/test.dart';

void main() {
  test('parses docker config and generates dockerfile plus bake file', () async {
    final dir = await Directory.systemTemp.createTemp('hippo_docker_');
    addTearDown(() => dir.delete(recursive: true));
    await File('${dir.path}/docker.yaml').writeAsString('''
source: https://example.com/repo
flutter_version: "3.44.0"
images:
  server:
    type: dart_server
    package: server
    target: bin/main.dart
    executable: server
    expose: 3000
    title: Server
''');

    final result = await DockerGenerator(projectRoot: dir).generate();

    expect(result.images.single.name, 'server');
    expect(
      await result.images.single.dockerfile.readAsString(),
      contains('dart compile exe server/bin/main.dart'),
    );
    expect(await result.bakeFile.readAsString(), contains('target "server"'));
  });
}
