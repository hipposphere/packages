import 'package:hippo_cli_build/hippo_cli_build.dart';
import 'package:test/test.dart';

void main() {
  test('parses flutter release targets and expands variables', () {
    final config = FlutterReleaseConfig.parse(r'''
variables:
  API_URL: https://api.example.com
targets:
  web_release:
    platform: web
    package: app
    dart_defines:
      API_URL: ${API_URL}
    build_args:
      - --wasm
''');

    final target = config.target('web_release');

    expect(target.platform, FlutterReleasePlatform.web);
    expect(target.dartDefines['API_URL'], 'https://api.example.com');
    expect(flutterBuildCommand(target), contains('--dart-define=API_URL=https://api.example.com'));
    expect(artifactPaths(config, 'web_release'), ['app/build/web']);
  });
}
