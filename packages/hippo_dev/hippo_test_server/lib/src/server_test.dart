import 'package:hippo_test_core/hippo_test_core.dart';
import 'package:test/test.dart';

void serverTest(
  String id,
  String description, {
  required Future<void> Function(ScenarioRecorder scenario, TestResources resources) run,
  Timeout timeout = const Timeout(Duration(minutes: 2)),
}) {
  test('[$id] $description', () async {
    final recorder = ScenarioRecorder(id: id, description: description, kind: 'server-integration');
    final resources = TestResources();
    addTearDown(resources.close);
    try {
      await run(recorder, resources);
      recorder.finish();
    } catch (error, stack) {
      recorder.finish(error: error, stack: stack);
      rethrow;
    }
  }, timeout: timeout);
}
