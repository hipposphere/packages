import 'planning.dart';

/// One read-only GET call to a source: a path below its base URL and query
/// parameters. A client resolves it against the source's base URL, so a
/// reverse-proxy prefix is kept.
final class WireRequest {
  const WireRequest(this.path, [this.query = const {}]);

  /// Path segments below the base URL, such as `['api', 'v1', 'query']`.
  final List<String> path;
  final Map<String, String> query;

  /// This request against [base]: its path segments are appended and [query]
  /// replaces the query.
  Uri resolve(Uri base) => base.replace(
    pathSegments: [...base.pathSegments.where((segment) => segment.isNotEmpty), ...path],
    queryParameters: query.isEmpty ? null : query,
  );

  @override
  String toString() =>
      '/${path.join('/')}${query.isEmpty ? '' : '?${Uri(queryParameters: query).query}'}';
}

/// Requests of the Prometheus HTTP API.
abstract final class PrometheusRequests {
  static WireRequest query(String expression, {required DateTime time}) =>
      WireRequest(['api', 'v1', 'query'], {'query': expression, 'time': unixSeconds(time)});

  static WireRequest queryRange(
    String expression, {
    required DateTime start,
    required DateTime end,
    required int stepSeconds,
  }) => WireRequest(
    ['api', 'v1', 'query_range'],
    {
      'query': expression,
      'start': unixSeconds(start),
      'end': unixSeconds(end),
      'step': '$stepSeconds',
    },
  );

  /// Label names, or the values of [label]; [match] is a series selector.
  static WireRequest labels({
    required DateTime start,
    required DateTime end,
    String? label,
    String? match,
  }) => WireRequest(
    [
      'api',
      'v1',
      ...label == null ? ['labels'] : ['label', label, 'values'],
    ],
    {'start': unixSeconds(start), 'end': unixSeconds(end), 'match[]': ?match},
  );
}

/// Requests of the Loki HTTP API.
abstract final class LokiRequests {
  /// A log or metric query over a range. [step] applies to metric queries;
  /// [limit] to log queries; [backward] returns the newest lines first.
  static WireRequest queryRange(
    String expression, {
    required DateTime start,
    required DateTime end,
    required int limit,
    int? stepSeconds,
    bool backward = false,
  }) => WireRequest(
    ['loki', 'api', 'v1', 'query_range'],
    {
      'query': expression,
      'start': unixNanos(start),
      'end': unixNanos(end),
      if (stepSeconds != null) 'step': '$stepSeconds',
      'limit': '$limit',
      if (backward) 'direction': 'backward',
    },
  );

  static WireRequest query(String expression, {required DateTime time, required int limit}) =>
      WireRequest(
        ['loki', 'api', 'v1', 'query'],
        {'query': expression, 'time': unixNanos(time), 'limit': '$limit'},
      );

  static WireRequest labels({
    required DateTime start,
    required DateTime end,
    String? label,
    String? match,
  }) => WireRequest(
    [
      'loki',
      'api',
      'v1',
      ...label == null ? ['labels'] : ['label', label, 'values'],
    ],
    {'start': unixNanos(start), 'end': unixNanos(end), 'query': ?match},
  );
}

/// Requests of the Tempo HTTP API.
abstract final class TempoRequests {
  /// TraceQL search.
  static WireRequest search(
    String traceql, {
    required DateTime start,
    required DateTime end,
    required int limit,
  }) => WireRequest(
    ['api', 'search'],
    {
      'q': traceql,
      'start': wholeUnixSeconds(start),
      'end': wholeUnixSeconds(end),
      'limit': '$limit',
    },
  );

  /// A trace by hex ID. Tempo before 2.5 has no v2 route and answers 404;
  /// try [traceV1] then.
  static WireRequest traceV2(String hexId) => WireRequest(['api', 'v2', 'traces', hexId]);

  static WireRequest traceV1(String hexId) => WireRequest(['api', 'traces', hexId]);

  /// Tag names (v2 groups them by scope), or the values of [tag].
  static WireRequest tags({
    required DateTime start,
    required DateTime end,
    String? tag,
    String? match,
  }) => WireRequest(
    [
      'api',
      'v2',
      'search',
      ...tag == null ? ['tags'] : ['tag', tag, 'values'],
    ],
    {'start': wholeUnixSeconds(start), 'end': wholeUnixSeconds(end), 'q': ?match},
  );
}
