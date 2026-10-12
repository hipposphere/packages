import 'dart:convert';

/// Report artifacts stay inside the exported directory, including under file://.
String? artifactPath(Object? value) {
  if (value is! String ||
      !RegExp(
        r'^[a-zA-Z0-9][a-zA-Z0-9._ /-]*\.(png|webp|jpg|jpeg|mp4|webm)$',
        caseSensitive: false,
      ).hasMatch(value) ||
      value.split('/').any((part) => part.isEmpty || part == '.' || part == '..')) {
    return null;
  }
  return Uri(path: value).toString();
}

List<Map<String, dynamic>> records(Object? value) {
  if (value == null) return [];
  if (value is! List || value.any((entry) => entry is! Map<String, dynamic>)) {
    throw const FormatException('Invalid report record list');
  }
  return value.cast<Map<String, dynamic>>();
}

String duration(Object? milliseconds) {
  final value = milliseconds is num ? milliseconds : 0;
  return value < 1000 ? '${value.round()} ms' : '${(value / 1000).toStringAsFixed(1)} s';
}

class TestRun {
  TestRun.fromJson(String source) {
    final data = jsonDecode(source);
    if (data is! Map<String, dynamic> || data['exitCode'] is! int || data['cases'] is! List) {
      throw const FormatException('This file is not a Hippo test report');
    }
    if (data['schemaVersion'] != null && data['schemaVersion'] != 1) {
      throw const FormatException('Unsupported report version. Rebuild with a matching viewer.');
    }
    exitCode = data['exitCode'] as int;
    cases = records(data['cases']).map(Scenario.new).toList();
    command = '${data['command'] ?? ''}';
    environment = '${data['environment'] ?? ''}';
    runnerLog = '${data['runnerLog'] ?? ''}';
  }
  late final int exitCode;
  late final List<Scenario> cases;
  late final String command, environment, runnerLog;
  int get passed => cases.where((c) => c.status == 'passed').length;
  int get attention => cases.where((c) => c.status != 'passed' && c.status != 'skipped').length;
  int get goldenCount => cases.fold(
    0,
    (sum, c) => sum + c.shots.where((s) => s['golden'] != null || s['expected'] != null).length,
  );
  int get updatedCount =>
      cases.fold(0, (sum, c) => sum + c.shots.where((s) => s['status'] == 'updated').length);
}

class Scenario {
  Scenario(this.data)
    : steps = records(data['steps']),
      shots = records(data['checkpoints']),
      frames = records(data['frames']);
  final Map<String, dynamic> data;
  final List<Map<String, dynamic>> steps, shots, frames;
  String get title => '${data['description'] ?? data['name'] ?? 'Unnamed scenario'}';
  String get id => '${data['id'] ?? data['name'] ?? title}';
  String get status => '${data['status'] ?? 'incomplete'}';
  String get variant => '${data['variant'] ?? data['kind'] ?? 'runner'}';
  String get elapsed => duration(data['durationMs']);
  List<Map<String, dynamic>> get replay =>
      (frames.isNotEmpty ? frames : shots).where((f) => artifactPath(f['actual']) != null).toList();
  String? get video {
    final path = artifactPath(data['video']);
    return path != null && RegExp(r'\.(mp4|webm)$', caseSensitive: false).hasMatch(path)
        ? path
        : null;
  }

  String get errors => [
    data['error'],
    data['stack'],
    ...?data['runnerErrors'] is List ? data['runnerErrors'] as List : null,
    data['captureError'],
  ].where((e) => e != null).join('\n\n');
  bool matches(String query) =>
      '$title $id $variant ${data['kind']}'.toLowerCase().contains(query.toLowerCase());
}
