import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_test/report.dart';

void main() {
  test('a teardown failure overrides a successful feature body', () {
    final cases = <Map<String, dynamic>>[
      {'name': '[demo] Example', 'status': 'passed'},
    ];
    reconcileRunnerResults(cases, [
      {
        'type': 'testStart',
        'test': {'id': 1, 'name': '[demo] Example'},
      },
      {'type': 'error', 'testID': 1, 'error': 'database cleanup failed'},
      {'type': 'testDone', 'testID': 1, 'result': 'error', 'skipped': false},
    ]);
    expect(cases.single['status'], 'failed');
    expect(cases.single['runnerErrors'], contains(contains('database cleanup failed')));
  });

  test('a process that stops before testDone cannot report a pass', () {
    final cases = <Map<String, dynamic>>[
      {'name': '[demo] Example', 'status': 'passed'},
    ];
    reconcileRunnerResults(cases, []);
    expect(cases.single['status'], 'incomplete');
  });

  test('compilation failures are included even without feature records', () {
    final cases = <Map<String, dynamic>>[];
    reconcileRunnerResults(cases, [
      {
        'type': 'testStart',
        'test': {'id': 0, 'name': 'loading test.dart'},
      },
      {'type': 'error', 'testID': 0, 'error': 'Compilation failed'},
    ]);
    expect(cases.single['status'], 'failed');
    expect(cases.single['kind'], 'runner');
  });

  test('embedded report JSON cannot break out of its inert script element', () {
    final html = renderTestReport(
      cases: [
        {
          'description': '</script><script>alert(1)</script><img onerror=alert(2)>',
          'status': 'failed',
          'checkpoints': [
            {'name': 'Example', 'actual': 'case/actual.png', 'expected': 'case/expected.png'},
          ],
        },
      ],
      exitCode: 1,
      command: 'flutter test',
      environment: 'test',
      runnerLog: '<script>bad()</script>',
    );
    expect(html, isNot(contains('<script>')));
    expect(html, contains(r'\u003cscript\u003e'));
    final source = RegExp(
      r'id="hippo-report-data">(.*?)</script>',
      dotAll: true,
    ).firstMatch(html)!.group(1)!;
    final data = jsonDecode(source);
    expect(
      data['cases'][0]['description'],
      '</script><script>alert(1)</script><img onerror=alert(2)>',
    );
    expect(html, contains('Run failed'));
    expect(html, contains('viewer.js'));
    expect(html, contains('viewer.css'));
    expect(html, contains('expected.png'));
  });
}
