import 'dart:convert';

import 'package:hippo_test_viewer/src/report_model.dart';
import 'package:test/test.dart';

void main() {
  test('legacy reports retain runner outcome and checkpoint replay', () {
    final run = TestRun.fromJson(
      jsonEncode({
        'exitCode': 1,
        'cases': [
          {
            'id': 'local.mobile',
            'description': 'Local journey',
            'status': 'failed',
            'variant': 'mobile',
            'checkpoints': [
              {
                'name': 'Editor',
                'actual': 'local.mobile/0-actual.png',
                'expected': 'local.mobile/0-expected.png',
              },
            ],
            'runnerErrors': ['teardown failed'],
          },
        ],
      }),
    );
    expect(run.exitCode, 1);
    expect(run.attention, 1);
    expect(run.passed, 0);
    expect(run.goldenCount, 1);
    expect(run.cases.single.replay.single['name'], 'Editor');
    expect(run.cases.single.errors, contains('teardown failed'));
    expect(run.cases.single.matches('LOCAL'), isTrue);
    expect(run.cases.single.matches('mobile'), isTrue);
  });
  test('recorded steps take precedence over golden checkpoints', () {
    final scenario = Scenario({
      'frames': [
        {'name': 'Create', 'actual': 'a/step-0.png'},
        {'name': 'Invalid', 'actual': '../secret.png'},
      ],
      'checkpoints': [
        {'actual': 'a/0.png'},
      ],
    });
    expect(scenario.replay.length, 1);
    expect(scenario.replay.single['name'], 'Create');
  });
  test('only contained image and video artifact paths can be loaded', () {
    for (final path in [
      '../outside.png',
      'a/../../outside.png',
      '/private.png',
      'https://host/shot.png',
      '//host/shot.png',
      'a\\file.png',
      'data:image/png;base64,abc',
      'a/%2e%2e/secret.png',
      'a/image.png?redirect=x',
      'a//image.png',
      'a/./image.png',
      'a/script.svg',
    ]) {
      expect(artifactPath(path), isNull, reason: path);
    }
    expect(artifactPath('a/step 1.png'), 'a/step%201.png');
    expect(artifactPath('a/recording.webm'), 'a/recording.webm');
  });
  test('malformed data and unsupported versions fail clearly', () {
    for (final source in [
      'no json',
      '[]',
      '{}',
      '{"exitCode":0,"cases":[1]}',
      '{"schemaVersion":2,"exitCode":0,"cases":[]}',
      '{"exitCode":0,"cases":[{"steps":"bad"}]}',
    ]) {
      expect(() => TestRun.fromJson(source), throwsFormatException);
    }
  });
  test('updated goldens are visible separately from passed assertions', () {
    final run = TestRun.fromJson(
      '{"exitCode":0,"cases":[{"status":"passed","checkpoints":[{"status":"updated","golden":"new.png"}]}]}',
    );
    expect(run.updatedCount, 1);
    expect(run.goldenCount, 1);
    expect(run.passed, 1);
  });
}
