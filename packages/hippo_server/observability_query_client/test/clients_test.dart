import 'dart:async';
import 'dart:convert';

import 'package:dart_http_core/dart_http_core.dart';
import 'package:observability_query_client/observability_query_client.dart';
import 'package:test/test.dart';

/// Answers each request from [handler] and records it.
final class FakeTransport implements HttpClientTransport {
  FakeTransport(this.handler);

  final Stream<List<int>> Function(DartHttpClientRequest request, int index) handler;
  final requests = <DartHttpClientRequest>[];
  final statuses = <int>[];
  int status = 200;
  String contentType = 'application/json';

  @override
  Future<DartHttpClientResponse> send(DartHttpClientRequest request) =>
      throw UnimplementedError('The clients stream responses.');

  @override
  Future<DartHttpClientStreamedResponse> sendStream(DartHttpClientRequest request) async {
    requests.add(request);
    final code = statuses.isEmpty ? status : statuses[requests.length - 1];
    return DartHttpClientStreamedResponse(
      status: code,
      contentType: contentType,
      bodyStream: handler(request, requests.length - 1),
    );
  }
}

Stream<List<int>> json(Object value) => Stream.value(utf8.encode(jsonEncode(value)));

Stream<List<int>> text(String value) => Stream.value(utf8.encode(value));

ObservabilitySource source(
  FakeTransport transport, {
  String? bearer,
  String? username,
  String? password,
  String? tenant,
  Uri? baseUri,
  Duration timeout = const Duration(seconds: 5),
  int maxBytes = 1024 * 1024,
}) => ObservabilitySource(
  baseUri: baseUri ?? Uri.parse('https://prom.internal:9090/proxy'),
  transport: transport,
  bearerToken: bearer,
  username: username,
  password: password,
  tenantId: tenant,
  timeout: timeout,
  maxResponseBytes: maxBytes,
);

void main() {
  final start = DateTime.utc(2026, 11, 10, 8);
  final end = DateTime.utc(2026, 11, 10, 9);

  group('ObservabilitySource', () {
    test('sends a GET below the base path with auth, tenant and no redirects', () async {
      final transport = FakeTransport(
        (_, _) => json({
          'status': 'success',
          'data': ['a'],
        }),
      );
      final prom = PrometheusClient(source(transport, bearer: 'tok-123456', tenant: 'tenant-a'));
      expect(await prom.labels(start: start, end: end), ['a']);
      final request = transport.requests.single;
      expect(request.method, HttpMethod.get);
      expect(request.uri.path, '/proxy/api/v1/labels');
      expect(request.headers['authorization'], 'Bearer tok-123456');
      expect(request.headers['X-Scope-OrgID'], 'tenant-a');
      expect(request.headers['accept'], 'application/json');
      expect(request.redirectPolicy, DartHttpClientRedirectPolicy.none);
    });

    test('basic auth is encoded and a bearer token wins over it', () async {
      final transport = FakeTransport((_, _) => json({'status': 'success', 'data': []}));
      await PrometheusClient(source(transport, username: 'u', password: 'p'))
          .labels(start: start, end: end);
      expect(
        transport.requests.single.headers['authorization'],
        'Basic ${base64Encode(utf8.encode('u:p'))}',
      );
      final second = FakeTransport((_, _) => json({'status': 'success', 'data': []}));
      await PrometheusClient(source(second, bearer: 'tok', username: 'u', password: 'p'))
          .labels(start: start, end: end);
      expect(second.requests.single.headers['authorization'], 'Bearer tok');
    });

    test('a redirect is refused without leaking the target', () async {
      final transport = FakeTransport((_, _) => text(''))..status = 302;
      await expectLater(
        PrometheusClient(source(transport)).labels(start: start, end: end),
        throwsA(
          isA<ObservabilityUpstreamException>().having(
            (e) => e.message,
            'message',
            'The source answered with a redirect (HTTP 302), which is refused',
          ),
        ),
      );
    });

    test('a response over the limit fails and aborts the request', () async {
      final transport = FakeTransport(
        (_, _) => Stream.fromIterable([List.filled(600, 120), List.filled(600, 120)]),
      );
      await expectLater(
        PrometheusClient(source(transport, maxBytes: 1000)).labels(start: start, end: end),
        throwsA(
          isA<ObservabilityUpstreamException>().having(
            (e) => e.message,
            'message',
            contains('exceeds the 1 KiB limit'),
          ),
        ),
      );
      var aborted = false;
      unawaited(transport.requests.single.abortTrigger!.then((_) => aborted = true));
      await Future<void>.delayed(Duration.zero);
      expect(aborted, isTrue);
    });

    test('a slow source times out', () async {
      final transport = FakeTransport((_, _) => Completer<List<int>>().future.asStream());
      await expectLater(
        PrometheusClient(source(transport, timeout: const Duration(milliseconds: 50)))
            .labels(start: start, end: end),
        throwsA(
          isA<ObservabilityUpstreamException>().having(
            (e) => e.message,
            'message',
            startsWith('The source did not answer within'),
          ),
        ),
      );
    });

    test('transport failures never name the host', () async {
      final transport = FakeTransport(
        (_, _) => throw StateError('connect to prom.internal:9090 failed'),
      );
      await expectLater(
        PrometheusClient(source(transport)).labels(start: start, end: end),
        throwsA(
          isA<ObservabilityUpstreamException>().having(
            (e) => e.message,
            'message',
            'The source is unreachable',
          ),
        ),
      );
    });

    test('errors keep the backend text but not URLs or tokens', () async {
      final transport = FakeTransport(
        (_, _) => json({
          'status': 'error',
          'errorType': 'bad_data',
          'error': 'parse error at tok-123456 via https://prom.internal:9090/proxy',
        }),
      )..status = 400;
      await expectLater(
        PrometheusClient(source(transport, bearer: 'tok-123456')).query('up{', time: end),
        throwsA(
          isA<ObservabilityUpstreamException>()
              .having((e) => e.message, 'message', 'parse error at [redacted] via [redacted]')
              .having((e) => e.rejected, 'rejected', isTrue),
        ),
      );
    });
  });

  group('PrometheusClient', () {
    test('a range query sends the planned step and returns a wide frame', () async {
      final transport = FakeTransport(
        (_, _) => json({
          'status': 'success',
          'warnings': ['careful'],
          'data': {
            'resultType': 'matrix',
            'result': [
              {
                'metric': {'job': 'api'},
                'values': [
                  [1000, '1'],
                  [1015, '2'],
                ],
              },
            ],
          },
        }),
      );
      final result = await PrometheusClient(source(transport))
          .queryRange('up', start: start, end: end, stepSeconds: 15, name: 'A', legend: '{{job}}');
      final request = transport.requests.single;
      expect(request.uri.queryParameters['step'], '15');
      expect(request.uri.queryParameters['query'], 'up');
      final frame = result.frames.single;
      expect(frame.fields[1].displayName, 'api');
      expect(frame.fields[1].numbers, [1, 2]);
      expect(result.notices, ['careful']);
    });
  });

  group('LokiClient', () {
    test('log queries come back as one frame per stream', () async {
      final transport = FakeTransport(
        (_, _) => json({
          'status': 'success',
          'data': {
            'resultType': 'streams',
            'result': [
              {
                'stream': {'service': 'api'},
                'values': [
                  ['2000000000', 'two'],
                  ['1000000000', 'one'],
                ],
              },
            ],
          },
        }),
      );
      final result = await LokiClient(source(transport))
          .queryRange('{service="api"}', start: start, end: end, limit: 10);
      final request = transport.requests.single;
      expect(request.uri.path, '/proxy/loki/api/v1/query_range');
      expect(request.uri.queryParameters['direction'], 'backward');
      expect(request.uri.queryParameters['limit'], '10');
      expect(result.frames.single.kind, WireFrameKind.logs);
      expect(result.frames.single.fields[1].strings, ['two', 'one']);
    });

    test('a metric query over logs returns a time series', () async {
      final transport = FakeTransport(
        (_, _) => json({
          'status': 'success',
          'data': {
            'resultType': 'matrix',
            'result': [
              {
                'metric': {'level': 'error'},
                'values': [
                  [1000, '3'],
                ],
              },
            ],
          },
        }),
      );
      final result = await LokiClient(source(transport)).queryRange(
        'sum by (level) (count_over_time({a="b"}[1m]))',
        start: start,
        end: end,
        stepSeconds: 60,
        backward: false,
      );
      expect(transport.requests.single.uri.queryParameters['step'], '60');
      expect(transport.requests.single.uri.queryParameters.containsKey('direction'), isFalse);
      expect(result.frames.single.kind, WireFrameKind.timeSeries);
    });

    test('plain-text errors from Loki reach the caller', () async {
      final transport = FakeTransport((_, _) => text('parse error at line 1'))
        ..status = 400
        ..contentType = 'text/plain; charset=utf-8';
      await expectLater(
        LokiClient(source(transport)).queryRange('{', start: start, end: end),
        throwsA(
          isA<ObservabilityUpstreamException>().having(
            (e) => e.message,
            'message',
            'parse error at line 1',
          ),
        ),
      );
    });
  });

  group('TempoClient', () {
    Map<String, Object?> trace() => {
      'trace': {
        'resourceSpans': [
          {
            'resource': {
              'attributes': [
                {
                  'key': 'service.name',
                  'value': {'stringValue': 'api'},
                },
              ],
            },
            'scopeSpans': [
              {
                'spans': [
                  {
                    'spanId': '0102030405060708',
                    'name': 'root',
                    'startTimeUnixNano': '1000000000',
                    'endTimeUnixNano': '2000000000',
                  },
                ],
              },
            ],
          },
        ],
      },
    };

    test('a trace falls back to the v1 route when v2 is missing', () async {
      final transport = FakeTransport((_, index) => index == 0 ? text('not found') : json(trace()))
        ..statuses.addAll([404, 200])
        ..contentType = 'text/plain';
      final spans = await TempoClient(source(transport)).trace('ABC');
      expect(spans!.single.name, 'root');
      expect(transport.requests.map((r) => r.uri.path), [
        '/proxy/api/v2/traces/${'0' * 29}abc',
        '/proxy/api/traces/${'0' * 29}abc',
      ]);
    });

    test('an unknown trace is null, an invalid id is not even requested', () async {
      final transport = FakeTransport((_, _) => text('not found'))
        ..status = 404
        ..contentType = 'text/plain';
      expect(await TempoClient(source(transport)).trace('abcd'), isNull);
      expect(transport.requests, hasLength(2));
      final before = transport.requests.length;
      expect(await TempoClient(source(transport)).trace('not a trace id'), isNull);
      expect(transport.requests, hasLength(before));
    });

    test('search returns a table of traces and tags are scoped', () async {
      final transport = FakeTransport(
        (_, index) => index == 0
            ? json({
                'traces': [
                  {'traceID': 'ab', 'rootServiceName': 'api', 'durationMs': 5},
                ],
              })
            : json({
                'scopes': [
                  {
                    'name': 'span',
                    'tags': ['http.method'],
                  },
                ],
              }),
      );
      final client = TempoClient(source(transport));
      final result = await client.search('{ status = error }', start: start, end: end, limit: 5);
      expect(result.frames.single.fields[1].strings, ['api']);
      expect(await client.tags(start: start, end: end), ['span.http.method']);
    });
  });
}
