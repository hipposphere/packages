import 'package:observability_wire/observability_wire.dart';

import 'source.dart';

/// PromQL against the Prometheus HTTP API.
final class PrometheusClient {
  const PrometheusClient(this.source);

  final ObservabilitySource source;

  /// An instant query at [time].
  Future<WireResult> query(
    String expression, {
    required DateTime time,
    int maxSeries = 500,
    String? name,
    String? legend,
    String? unit,
  }) async {
    final json = await source.getJson(PrometheusRequests.query(expression, time: time));
    return _metrics(source, json, time, maxSeries, name, legend, unit);
  }

  /// A range query; [stepSeconds] is used as given (see [planStepSeconds]).
  Future<WireResult> queryRange(
    String expression, {
    required DateTime start,
    required DateTime end,
    required int stepSeconds,
    int maxSeries = 500,
    String? name,
    String? legend,
    String? unit,
  }) async {
    final json = await source.getJson(
      PrometheusRequests.queryRange(expression, start: start, end: end, stepSeconds: stepSeconds),
    );
    return _metrics(source, json, end, maxSeries, name, legend, unit);
  }

  /// Label names, or with [label] its values; [match] is a series selector.
  Future<List<String>> labels({
    required DateTime start,
    required DateTime end,
    String? label,
    String? match,
  }) async => envelopeStrings(
    await source.getJson(
      PrometheusRequests.labels(start: start, end: end, label: label, match: match),
    ),
  );

  /// Metric names.
  Future<List<String>> metricNames({required DateTime start, required DateTime end}) =>
      labels(start: start, end: end, label: '__name__');
}

WireResult _metrics(
  ObservabilitySource source,
  Object? json,
  DateTime evaluatedAt,
  int maxSeries,
  String? name,
  String? legend,
  String? unit,
) {
  final result = normalizeMetricData(
    envelopeData(json),
    evaluatedAt: evaluatedAt,
    maxSeries: maxSeries,
    name: name,
    legend: legend,
    unit: unit,
  );
  return WireResult(
    result.frames,
    limited: result.limited,
    notices: [...result.notices, ..._notices(source, json)],
  );
}

/// Warnings of the backend, without its URL or credentials.
List<String> _notices(ObservabilitySource source, Object? json) => [
  for (final notice in envelopeNotices(json)) redactText(notice, source.secrets),
];

/// LogQL against the Loki HTTP API: log streams and metric queries.
final class LokiClient {
  const LokiClient(this.source);

  final ObservabilitySource source;

  /// A query over a range. A log query returns one `logs` frame per stream,
  /// newest first (set [backward]); a metric query returns a time series frame
  /// and uses [stepSeconds].
  Future<WireResult> queryRange(
    String expression, {
    required DateTime start,
    required DateTime end,
    int limit = 1000,
    int? stepSeconds,
    bool backward = true,
    int maxSeries = 500,
    String? name,
    String? legend,
    String? unit,
  }) async => _result(
    await source.getJson(
      LokiRequests.queryRange(
        expression,
        start: start,
        end: end,
        limit: limit,
        stepSeconds: stepSeconds,
        backward: backward,
      ),
    ),
    evaluatedAt: end,
    limit: limit,
    maxSeries: maxSeries,
    name: name,
    legend: legend,
    unit: unit,
  );

  /// A metric query at [time].
  Future<WireResult> query(
    String expression, {
    required DateTime time,
    int limit = 1000,
    int maxSeries = 500,
    String? name,
    String? legend,
    String? unit,
  }) async => _result(
    await source.getJson(LokiRequests.query(expression, time: time, limit: limit)),
    evaluatedAt: time,
    limit: limit,
    maxSeries: maxSeries,
    name: name,
    legend: legend,
    unit: unit,
  );

  /// Label names, or with [label] its values; [match] narrows by selector.
  Future<List<String>> labels({
    required DateTime start,
    required DateTime end,
    String? label,
    String? match,
  }) async => envelopeStrings(
    await source.getJson(LokiRequests.labels(start: start, end: end, label: label, match: match)),
  );

  WireResult _result(
    Object? json, {
    required DateTime evaluatedAt,
    required int limit,
    required int maxSeries,
    String? name,
    String? legend,
    String? unit,
  }) {
    final data = envelopeData(json);
    final result = data['resultType'] == 'streams'
        ? normalizeLokiStreams(data['result'] as List<Object?>, limit: limit)
        : normalizeMetricData(
            data,
            evaluatedAt: evaluatedAt,
            maxSeries: maxSeries,
            name: name,
            legend: legend,
            unit: unit,
          );
    return WireResult(
      result.frames,
      limited: result.limited,
      notices: [...result.notices, ..._notices(source, json)],
    );
  }
}

/// TraceQL search, trace lookup and tags against the Tempo HTTP API.
final class TempoClient {
  const TempoClient(this.source);

  final ObservabilitySource source;

  /// A TraceQL search: one `table` frame of matching traces.
  Future<WireResult> search(
    String traceql, {
    required DateTime start,
    required DateTime end,
    int limit = 100,
  }) async {
    final json = await source.getJson(
      TempoRequests.search(traceql, start: start, end: end, limit: limit),
    );
    if (json is! Map<Object?, Object?>) throw const FormatException('Expected an object');
    return normalizeTempoSearch(json, limit: limit);
  }

  /// The spans of the trace with [traceId] (hex or base64), or null when Tempo
  /// does not know it or the ID is invalid. Falls back to the v1 route for
  /// Tempo before 2.5.
  Future<List<WireSpan>?> trace(String traceId) async {
    final hex = normalizeTraceId(traceId);
    if (hex == null) return null;
    for (final request in [TempoRequests.traceV2(hex), TempoRequests.traceV1(hex)]) {
      try {
        final json = await source.getJson(request);
        if (json is! Map<Object?, Object?>) throw const FormatException('Expected an object');
        return parseTempoTrace(json);
      } on ObservabilityUpstreamException catch (error) {
        if (!error.notFound) rethrow;
      }
    }
    return null;
  }

  /// Tag names as TraceQL attributes, or with [tag] its values.
  Future<List<String>> tags({
    required DateTime start,
    required DateTime end,
    String? tag,
    String? match,
  }) async => parseTempoTags(
    await source.getJson(TempoRequests.tags(start: start, end: end, tag: tag, match: match)),
    values: tag != null,
  );
}
