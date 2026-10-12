/// Portable report document and authoritative test-runner reconciliation.
library;

import 'dart:convert';

/// JSON is embedded as inert text, so reports also work directly from file://.
/// Escape HTML delimiters even inside application/json to prevent script breakout.
String renderTestReport({
  required List<Map<String, dynamic>> cases,
  required int exitCode,
  required String command,
  required String environment,
  required String runnerLog,
}) {
  final data = jsonEncode({
    'schemaVersion': 1,
    'exitCode': exitCode,
    'cases': cases,
    'command': command,
    'environment': environment,
    'runnerLog': runnerLog,
  }).replaceAll('&', r'\u0026').replaceAll('<', r'\u003c').replaceAll('>', r'\u003e');
  return '''<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="color-scheme" content="light">
<title>Hippo test · ${exitCode == 0 ? 'Run passed' : 'Run failed'}</title>
<link rel="icon" href="data:,">
<link rel="stylesheet" href="viewer.css">
</head><body>
<div id="app"><p style="padding:32px">Opening Hippo test report… If this remains visible, copy the complete report folder including viewer.js and viewer.css.</p></div>
<noscript>This report needs JavaScript for inspection. <a href="results.json">Download results</a> or <a href="runner.log">read the runner log</a>.</noscript>
<script type="application/json" id="hippo-report-data">$data</script>
<script defer src="viewer.js"></script>
</body></html>''';
}

/// Flutter's final testDone result is authoritative, including late failures.
void reconcileRunnerResults(List<Map<String, dynamic>> cases, List<Map<String, dynamic>> events) {
  final names = <int, String>{};
  final outcomes = <String, String>{};
  final errors = <String, List<String>>{};
  for (final event in events) {
    if (event['type'] == 'testStart') {
      final test = event['test'] as Map<String, dynamic>;
      names[test['id'] as int] = test['name'] as String;
    }
    final name = names[event['testID']];
    if (name == null) continue;
    if (event['type'] == 'error') {
      errors.putIfAbsent(name, () => []).add('${event['error']}\n${event['stackTrace'] ?? ''}');
    }
    if (event['type'] == 'testDone') {
      outcomes[name] = event['skipped'] == true
          ? 'skipped'
          : event['result'] == 'success'
          ? 'passed'
          : 'failed';
    }
  }
  for (final test in cases) {
    final name = test['name'];
    test['status'] = outcomes[name] ?? 'incomplete';
    if (errors.containsKey(name)) test['runnerErrors'] = errors[name];
  }
  // Include compilation, setup, or other tests that failed before producing a record.
  for (final entry in errors.entries) {
    if (cases.any((test) => test['name'] == entry.key)) continue;
    cases.add({
      'name': entry.key,
      'description': entry.key,
      'kind': 'runner',
      'status': 'failed',
      'runnerErrors': entry.value,
    });
  }
}
