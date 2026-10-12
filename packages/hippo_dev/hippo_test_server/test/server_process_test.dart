import 'dart:convert';
import 'dart:io';

import 'package:hippo_test_core/hippo_test_core.dart';
import 'package:hippo_test_server/hippo_test_server.dart';
import 'package:test/test.dart';

void main() {
  final dart = Platform.environment['FLUTTER_ROOT'] == null
      ? Platform.resolvedExecutable
      : '${Platform.environment['FLUTTER_ROOT']}/bin/cache/dart-sdk/bin/dart';
  test('server process owns a real socket and shuts down cleanly', () async {
    final dir = await Directory.systemTemp.createTemp('hippo-server-process-');
    addTearDown(() => dir.delete(recursive: true));
    final script = File('${dir.path}/fixture.dart');
    await script.writeAsString('''
import 'dart:convert';import 'dart:io';
Future<void> main()async{
 final server=await HttpServer.bind('127.0.0.1',0);
 server.listen((r){r.response.write('real response');r.response.close();});
 stdout.writeln(jsonEncode({'hippo_test_ready':'http://127.0.0.1:\${server.port}'}));
 await stdin.transform(utf8.decoder).transform(const LineSplitter()).first;
 await server.close(force:true);
}
''');
    final resources = TestResources();
    addTearDown(resources.close);
    final fixture = await TestServerProcess.start(
      executable: dart,
      arguments: [script.path],
      workingDirectory: dir.path,
      resources: resources,
    );
    final http = HttpClient();
    addTearDown(() => http.close(force: true));
    expect(
      await utf8.decoder.bind(await (await http.getUrl(fixture.baseUri)).close()).join(),
      'real response',
    );
    await resources.close();
    expect(await fixture.process.exitCode, 0);
  }, timeout: const Timeout(Duration(seconds: 40)));
  test('startup failure preserves exit code and logs', () async {
    final dir = await Directory.systemTemp.createTemp('hippo-server-failure-');
    addTearDown(() => dir.delete(recursive: true));
    final script = File('${dir.path}/fixture.dart');
    await script.writeAsString(
      "import 'dart:io';void main(){stderr.writeln('fixture setup failed');exit(7);}",
    );
    final resources = TestResources();
    addTearDown(resources.close);
    await expectLater(
      TestServerProcess.start(
        executable: dart,
        arguments: [script.path],
        workingDirectory: dir.path,
        resources: resources,
      ),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          allOf(contains('7'), contains('fixture setup failed')),
        ),
      ),
    );
  }, timeout: const Timeout(Duration(seconds: 40)));
}
