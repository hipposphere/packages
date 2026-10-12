import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

String get hippoReportPath => const String.fromEnvironment('HIPPO_TEST_REPORT').isNotEmpty
    ? const String.fromEnvironment('HIPPO_TEST_REPORT')
    : Platform.environment['HIPPO_TEST_REPORT'] ?? '';

/// Common evidence schema for Flutter, server and combined journeys.
class ScenarioRecorder {
  ScenarioRecorder({
    required this.id,
    required String description,
    required String kind,
    Map<String, Object?> metadata = const {},
    String? reportPath,
  }) : reportPath = reportPath ?? hippoReportPath,
       data = {
         ...metadata,
         'id': id,
         'name': '[$id] $description',
         'description': description,
         'kind': kind,
         'status': 'running',
         'steps': <Map<String, Object?>>[],
         'checkpoints': <Map<String, Object?>>[],
         'frames': <Map<String, Object?>>[],
         'attachments': <Map<String, Object?>>[],
       } {
    if (!RegExp(r'^[a-z0-9][a-z0-9._-]*$').hasMatch(id)) {
      throw ArgumentError.value(id, 'id', 'Use lowercase letters, numbers, dots, _ and -');
    }
  }
  final String id, reportPath;
  final Map<String, Object?> data;
  final Stopwatch _clock = Stopwatch()..start();
  List<Map<String, Object?>> get steps => data['steps']! as List<Map<String, Object?>>;
  Future<T> step<T>(
    String name,
    Future<T> Function() action, {
    Future<void> Function(Map<String, Object?> entry)? after,
  }) async {
    final entry = <String, Object?>{'name': name, 'status': 'running'};
    steps.add(entry);
    write();
    final clock = Stopwatch()..start();
    try {
      final value = await action();
      entry['status'] = 'passed';
      return value;
    } catch (error) {
      entry.addAll({'status': 'failed', 'error': '$error'});
      rethrow;
    } finally {
      entry['durationMs'] = clock.elapsedMilliseconds;
      if (after != null) await after(entry);
      write();
    }
  }

  void finish({Object? error, StackTrace? stack}) {
    data.addAll({
      'status': error == null ? 'passed' : 'failed',
      'durationMs': _clock.elapsedMilliseconds,
    });
    if (error != null) data.addAll({'error': '$error', 'stack': '$stack'});
    write();
  }

  String saveBytes(String name, Uint8List bytes) {
    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(name) || name.startsWith('.')) {
      throw ArgumentError('Unsafe artifact filename');
    }
    final relative = '$id/$name';
    if (reportPath.isNotEmpty) {
      final file = File('$reportPath/$relative');
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(bytes);
    }
    return relative;
  }

  void evidence(String name, Object? value) {
    final entries = data['attachments']! as List<Map<String, Object?>>;
    final relative = saveBytes(
      'evidence-${entries.length}.json',
      Uint8List.fromList(utf8.encode(const JsonEncoder.withIndent('  ').convert(value))),
    );
    entries.add({'name': name, 'path': relative});
    write();
  }

  void attachText(String name, String text) {
    final entries = data['attachments']! as List<Map<String, Object?>>;
    final relative = saveBytes(
      'evidence-${entries.length}.log',
      Uint8List.fromList(utf8.encode(text)),
    );
    entries.add({'name': name, 'path': relative});
    write();
  }

  void write() {
    if (reportPath.isEmpty) return;
    final file = File('$reportPath/$id.json');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  }
}

/// Bounded condition wait. UI adapters can provide a pause that pumps their clock.
Future<void> waitUntil(
  Future<bool> Function() condition, {
  required String description,
  Duration timeout = const Duration(seconds: 15),
  Duration interval = const Duration(milliseconds: 25),
  Future<void> Function(Duration)? pause,
}) async {
  final clock = Stopwatch()..start();
  while (!await condition()) {
    if (clock.elapsed >= timeout) throw StateError('Timed out after $timeout: $description');
    await (pause ?? Future<void>.delayed)(interval);
  }
}
