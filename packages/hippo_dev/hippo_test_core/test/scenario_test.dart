import 'dart:convert';
import 'dart:io';

import 'package:hippo_test_core/hippo_test_core.dart';
import 'package:test/test.dart';

void main() {
  test('records original failures and durable evidence in the common schema', () async {
    final dir = Directory.systemTemp.createTempSync('hippo-core-');
    addTearDown(() => dir.deleteSync(recursive: true));
    final recorder = ScenarioRecorder(
      id: 'server.example',
      description: 'Real endpoint',
      kind: 'server-integration',
      reportPath: dir.path,
    );
    final failure = StateError('original');
    await expectLater(
      recorder.step('Call endpoint', () => Future<void>.error(failure)),
      throwsA(same(failure)),
    );
    recorder.evidence('State', {'pending': 2});
    recorder.finish(error: failure, stack: StackTrace.current);
    final data = jsonDecode(File('${dir.path}/server.example.json').readAsStringSync());
    expect(data['status'], 'failed');
    expect(data['steps'][0]['status'], 'failed');
    expect(jsonDecode(File('${dir.path}/${data['attachments'][0]['path']}').readAsStringSync()), {
      'pending': 2,
    });
    expect(
      () => recorder.saveBytes(
        '../outside.log',
        File('${dir.path}/server.example.json').readAsBytesSync(),
      ),
      throwsArgumentError,
    );
  });
  test('all resources close in reverse order and failures remain visible', () async {
    final order = <int>[];
    final resources = TestResources();
    resources.onCleanup(() async {
      order.add(1);
    });
    resources.onCleanup(() async {
      order.add(2);
      throw StateError('close failed');
    });
    resources.onCleanup(() async {
      order.add(3);
    });
    await expectLater(resources.close(), throwsA(isA<TestCleanupFailure>()));
    expect(order, [3, 2, 1]);
    await resources.close();
  });
  test('condition waits are bounded and name their unmet condition', () async {
    await expectLater(
      waitUntil(
        () => Future.value(false),
        description: 'client B received card',
        timeout: const Duration(milliseconds: 10),
        interval: const Duration(milliseconds: 1),
      ),
      throwsA(
        isA<StateError>().having((e) => e.message, 'message', contains('client B received card')),
      ),
    );
  });
}
