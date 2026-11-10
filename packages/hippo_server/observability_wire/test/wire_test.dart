import 'dart:convert';

import 'package:observability_wire/observability_wire.dart';
import 'package:test/test.dart';

void main() {
  group('planning', () {
    test('the step is raised so a range has at most maxPoints samples', () {
      const day = Duration(days: 1);
      expect(planStepSeconds(range: day, maxPoints: 1000), 87);
      expect(planStepSeconds(range: day, maxPoints: 1000, requested: 600), 600);
      expect(planStepSeconds(range: day, maxPoints: 1000, requested: 1), 87);
      expect(planStepSeconds(range: const Duration(seconds: 30), maxPoints: 1000), 1);
    });

    test('macros expand in both spellings and leave variables alone', () {
      const range = Duration(hours: 1);
      String expand(String text) => expandMacros(text, stepSeconds: 30, range: range);
      expect(expand(r'rate(x[$__rate_interval])'), 'rate(x[60s])');
      expect(expand(r'rate(x[${__rate_interval}])'), 'rate(x[60s])');
      expect(expand(r'increase(x[$__range])'), 'increase(x[3600s])');
      expect(expand(r'$__interval_ms $__range_ms $__range_s'), '30000 3600000 3600');
      expect(expand(r'$__intervalX $env'), r'$__intervalX $env');
      expect(
        expandMacros(
          r'[$__rate_interval]',
          stepSeconds: 120,
          range: range,
          scrapeIntervalSeconds: 30,
        ),
        '[150s]',
      );
    });

    test('times use the unit of each API', () {
      final time = DateTime.utc(2026, 11, 10, 9, 0, 0, 500);
      expect(unixSeconds(time), '1794301200.500');
      expect(wholeUnixSeconds(time), '1794301200');
      expect(unixNanos(time), '1794301200500000000');
    });
  });

  group('requests', () {
    final from = DateTime.utc(2026, 11, 10, 8);
    final to = DateTime.utc(2026, 11, 10, 9);

    test('resolve below a base URL with a proxy prefix', () {
      final request = PrometheusRequests.queryRange('up', start: from, end: to, stepSeconds: 15);
      final uri = request.resolve(Uri.parse('https://example.org/prom/'));
      expect(uri.path, '/prom/api/v1/query_range');
      expect(uri.queryParameters, {
        'query': 'up',
        'start': unixSeconds(from),
        'end': unixSeconds(to),
        'step': '15',
      });
    });

    test('label lookups pick the names or the values route', () {
      expect(PrometheusRequests.labels(start: from, end: to).path, ['api', 'v1', 'labels']);
      final values = PrometheusRequests.labels(start: from, end: to, label: 'job', match: 'up');
      expect(values.path, ['api', 'v1', 'label', 'job', 'values']);
      expect(values.query['match[]'], 'up');
      expect(LokiRequests.labels(start: from, end: to).path, ['loki', 'api', 'v1', 'labels']);
      expect(TempoRequests.tags(start: from, end: to, tag: 'span.x').path, [
        'api',
        'v2',
        'search',
        'tag',
        'span.x',
        'values',
      ]);
    });

    test('Loki log queries ask for the newest lines and a limit', () {
      final request = LokiRequests.queryRange(
        '{a="b"}',
        start: from,
        end: to,
        limit: 500,
        backward: true,
      );
      expect(request.query['direction'], 'backward');
      expect(request.query['limit'], '500');
      expect(request.query.containsKey('step'), isFalse);
      expect(request.query['start'], unixNanos(from));
    });

    test('Tempo search uses whole seconds', () {
      final request = TempoRequests.search('{ status = error }', start: from, end: to, limit: 20);
      expect(request.query['start'], wholeUnixSeconds(from));
      expect(request.query['q'], '{ status = error }');
    });
  });

  group('errors', () {
    test('a Prometheus error envelope keeps the source message without URLs', () {
      expect(
        () => decodeUpstreamJson(
          statusCode: 400,
          body: jsonEncode({
            'status': 'error',
            'error': 'parse error at http://prom.internal:9090/x: unexpected "}"',
          }),
          secrets: ['prom.internal'],
        ),
        throwsA(
          isA<ObservabilityUpstreamException>()
              .having((e) => e.rejected, 'rejected', isTrue)
              .having((e) => e.message, 'message', isNot(contains('prom.internal'))),
        ),
      );
    });

    test('plain-text errors are kept when short and redacted', () {
      expect(
        () => decodeUpstreamJson(
          statusCode: 400,
          body: 'parse error: bad token-secret-123 near http://loki:3100',
          contentType: 'text/plain',
          secrets: ['token-secret-123'],
        ),
        throwsA(
          isA<ObservabilityUpstreamException>().having(
            (e) => e.message,
            'message',
            'parse error: bad [redacted] near [redacted]',
          ),
        ),
      );
      expect(
        () => decodeUpstreamJson(statusCode: 502, body: '<html>bad gateway</html>'),
        throwsA(
          isA<ObservabilityUpstreamException>().having(
            (e) => e.message,
            'message',
            'The source answered with HTTP 502',
          ),
        ),
      );
    });

    test('a 2xx answer must be JSON', () {
      expect(
        () => decodeUpstreamJson(statusCode: 200, body: 'ok'),
        throwsA(isA<ObservabilityUpstreamException>()),
      );
      expect(
        decodeUpstreamJson(statusCode: 200, body: '{"status":"success"}'),
        isA<Map<dynamic, dynamic>>(),
      );
    });

    test('not found is detected', () {
      expect(
        () =>
            decodeUpstreamJson(statusCode: 404, body: 'page not found', contentType: 'text/plain'),
        throwsA(
          isA<ObservabilityUpstreamException>().having((e) => e.notFound, 'notFound', isTrue),
        ),
      );
    });

    test('redaction ignores very short secrets and shortens long text', () {
      expect(redactText('ab at abc', ['ab', 'abc']), 'ab at [redacted]');
      expect(redactText('x' * 3000, const []), hasLength(2001));
    });
  });

  group('metrics', () {
    final evaluated = DateTime.utc(2026, 11, 10, 9);

    test('a matrix becomes one wide frame with gaps as nulls', () {
      final result = normalizeMetricData(
        {
          'resultType': 'matrix',
          'result': [
            {
              'metric': {'__name__': 'up', 'job': 'api'},
              'values': [
                [1000, '1'],
                [1015, '1'],
              ],
            },
            {
              'metric': {'job': 'db'},
              'values': [
                [1015, 'NaN'],
                [1030, '0.5'],
              ],
            },
          ],
        },
        evaluatedAt: evaluated,
        maxSeries: 10,
        name: 'A',
        legend: '{{job}}!',
        unit: 's',
      );
      final frame = result.frames.single;
      expect(frame.kind, WireFrameKind.timeSeries);
      expect(frame.name, 'A');
      expect(frame.fields.first.numbers, [1000000, 1015000, 1030000]);
      final up = frame.fields[1];
      expect(up.name, 'up{job="api"}');
      expect(up.displayName, 'api!');
      expect(up.unit, 's');
      expect(up.numbers, [1, 1, null]);
      expect(frame.fields[2].name, '{job="db"}');
      expect(frame.fields[2].numbers, [null, null, 0.5], reason: 'NaN is missing');
    });

    test('series beyond the cap are cut and reported', () {
      final result = normalizeMetricData(
        {
          'resultType': 'vector',
          'result': [
            for (var i = 0; i < 5; i++)
              {
                'metric': {'i': '$i'},
                'value': [1000, '$i'],
              },
          ],
        },
        evaluatedAt: evaluated,
        maxSeries: 2,
      );
      expect(result.limited, isTrue);
      expect(result.notices.single, 'Showing the first 2 of 5 series');
      expect(result.frames.single.fields, hasLength(3));
      expect(result.frames.single.fields.first.numbers, [evaluated.millisecondsSinceEpoch]);
    });

    test('scalars and strings become one row, native histograms are noted', () {
      final scalar = normalizeMetricData(
        {
          'resultType': 'scalar',
          'result': [1000, '4'],
        },
        evaluatedAt: evaluated,
        maxSeries: 1,
      );
      expect(scalar.frames.single.fields[1].numbers, [4]);
      final text = normalizeMetricData(
        {
          'resultType': 'string',
          'result': [1000, 'hello'],
        },
        evaluatedAt: evaluated,
        maxSeries: 1,
      );
      expect(text.frames.single.fields[1].strings, ['hello']);
      final histogram = normalizeMetricData(
        {
          'resultType': 'vector',
          'result': [
            {'metric': <String, String>{}, 'histogram': <Object?>[]},
          ],
        },
        evaluatedAt: evaluated,
        maxSeries: 1,
      );
      expect(histogram.notices.single, contains('histogram'));
      expect(
        () => normalizeMetricData(
          {'resultType': 'bogus', 'result': []},
          evaluatedAt: evaluated,
          maxSeries: 1,
        ),
        throwsFormatException,
      );
    });

    test('envelopes yield data, notices and string lists', () {
      expect(
        envelopeData({
          'data': {'a': 1},
        }),
        {'a': 1},
      );
      expect(() => envelopeData({}), throwsFormatException);
      expect(
        envelopeNotices({
          'warnings': ['w'],
          'infos': ['i'],
        }),
        ['w', 'i'],
      );
      expect(
        envelopeStrings({
          'data': ['a', 1],
        }),
        ['a', '1'],
      );
    });
  });

  group('loki', () {
    test('streams become one logs frame each, newest first, with truncation', () {
      final long = 'x' * (maxLogLineLength + 10);
      final result = normalizeLokiStreams([
        {
          'stream': {'service': 'a', 'level': 'info'},
          'values': [
            ['1000000000', 'old'],
            ['3000000000', 'new'],
          ],
        },
        {
          'stream': {'service': 'b'},
          'values': [
            ['5000000000', long],
          ],
        },
      ], limit: 3);
      expect(result.frames.map((f) => f.name), ['{service="b"}', '{level="info", service="a"}']);
      final first = result.frames.last;
      expect(first.labels, const [WireLabel('level', 'info'), WireLabel('service', 'a')]);
      expect(first.fields[0].numbers, [3000, 1000]);
      expect(first.fields[1].strings, ['new', 'old']);
      expect(result.frames.first.fields[1].strings!.single!.length, maxLogLineLength + 1);
      expect(result.limited, isTrue);
      expect(result.notices, contains('1 lines longer than 16 KiB were truncated'));
    });
  });

  group('tempo', () {
    test('trace IDs accept hex and base64 and pad', () {
      expect(normalizeTraceId('ABC'), '0' * 29 + 'abc');
      expect(normalizeTraceId(base64.encode(List.filled(16, 0xab))), 'ab' * 16);
      expect(normalizeTraceId('not hex!'), isNull);
      expect(normalizeTraceId(''), isNull);
      expect(normalizeTraceId('a' * 33), isNull);
    });

    test('search becomes a table of traces', () {
      final result = normalizeTempoSearch({
        'traces': [
          {
            'traceID': 'ab12',
            'rootServiceName': 'api',
            'rootTraceName': 'POST /x',
            'startTimeUnixNano': '1700000000000000000',
            'durationMs': 12,
          },
          {'traceID': 'cd', 'startTimeUnixNano': 'bad'},
        ],
      }, limit: 2);
      final frame = result.frames.single;
      expect(frame.kind, WireFrameKind.table);
      expect(frame.fields[0].strings, ['${'0' * 28}ab12', '${'0' * 30}cd']);
      expect(frame.fields[3].numbers, [1700000000000, null]);
      expect(frame.fields[4].numbers, [12, 0]);
      expect(frame.fields[4].unit, 'ms');
      expect(result.limited, isTrue);
    });

    Map<Object?, Object?> otlp({required String spanKey}) => {
      'resourceSpans': [
        {
          'resource': {
            'attributes': [
              {
                'key': 'service.name',
                'value': {'stringValue': 'api'},
              },
              {
                'key': 'host',
                'value': {'intValue': '7'},
              },
            ],
          },
          spanKey: [
            {
              'spans': [
                {
                  'spanId': base64.encode(List.filled(8, 1)),
                  'name': 'child',
                  'startTimeUnixNano': '2000000000',
                  'endTimeUnixNano': '2005000000',
                  'parentSpanId': base64.encode(List.filled(8, 2)),
                  'status': {'code': 'STATUS_CODE_ERROR', 'message': 'boom'},
                  'attributes': [
                    {
                      'key': 'tags',
                      'value': {
                        'arrayValue': {
                          'values': [
                            {'stringValue': 'a'},
                            {'boolValue': true},
                          ],
                        },
                      },
                    },
                  ],
                },
                {
                  'spanId': '0202020202020202',
                  'name': 'root',
                  'startTimeUnixNano': '1000000000',
                  'endTimeUnixNano': '3000000000',
                  'status': {'code': 1},
                },
              ],
            },
          ],
        },
      ],
    };

    test('a v2 trace parses into spans sorted by start', () {
      final spans = parseTempoTrace({'trace': otlp(spanKey: 'scopeSpans')});
      expect(spans.map((s) => s.name), ['root', 'child']);
      final child = spans.last;
      expect(child.spanId, '01' * 8);
      expect(child.parentSpanId, '02' * 8);
      expect(child.service, 'api');
      expect(child.durationMs, 5);
      expect(child.status, 'error');
      expect(child.statusMessage, 'boom');
      expect(child.attributes.map((a) => '${a.name}=${a.value}'), [
        'tags=[a, true]',
        'resource.service.name=api',
        'resource.host=7',
      ]);
      expect(spans.first.status, 'ok');
      expect(spans.first.parentSpanId, isNull);
      expect(spans.first.start, DateTime.utc(1970, 1, 1, 0, 0, 1));
    });

    test('v1 batches with instrumentation library spans parse too', () {
      final v1 = otlp(spanKey: 'instrumentationLibrarySpans');
      final spans = parseTempoTrace({'batches': v1['resourceSpans']});
      expect(spans, hasLength(2));
    });

    test('tags are scoped and values may be strings or objects', () {
      expect(
        parseTempoTags({
          'scopes': [
            {
              'name': 'span',
              'tags': ['http.method'],
            },
            {
              'name': 'intrinsic',
              'tags': ['duration'],
            },
          ],
        }, values: false),
        ['span.http.method', 'duration'],
      );
      expect(
        parseTempoTags({
          'tagValues': [
            {'type': 'string', 'value': 'GET'},
            'POST',
          ],
        }, values: true),
        ['GET', 'POST'],
      );
    });
  });
}
