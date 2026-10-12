# hippo_test_core

Plain Dart recording and report infrastructure shared by Flutter, server and combined journeys. It has no Flutter or Jaspr runtime dependency. The optimized viewer is bundled as release assets.

`ScenarioRecorder` owns stable scenario IDs, named steps, statuses, durations, JSON/log evidence and the common report schema. `TestResources` attempts cleanup in reverse order, including after failures. `waitUntil` provides bounded condition waits; UI adapters supply their own clock-pumping pause.

Reports use schema version 1. Flutter's existing `hippo_test/report.dart` imports remain compatible through exports. Server evidence appears beside screenshots and replay in the same portable viewer. Download/copy the entire report directory.

```dart
final recorder = ScenarioRecorder(id: 'sync.client-b', description: 'Client B receives an edit', kind: 'client-server-end-to-end');
await recorder.step('Verify persisted state', () async { /* product assertions */ });
recorder.evidence('Queue after acknowledgement', {'pending': 0});
```

`runHippoTests` supports Flutter's machine reporter or Dart's JSON reporter and reconciles final runner outcomes, including teardown failures. The server runner supplies the report directory through the environment; Flutter supplies a compile-time define.
