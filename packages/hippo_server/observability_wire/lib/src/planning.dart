import 'dart:math' as math;

/// The step in whole seconds: the requested step (default `range / 1000`),
/// raised so that `range / step <= maxPoints`, and at least one second.
int planStepSeconds({required Duration range, required int maxPoints, num? requested}) {
  final seconds = range.inMilliseconds / 1000;
  final wanted = requested != null && requested > 0 ? requested : seconds / 1000;
  return math.max(1, math.max(wanted, seconds / maxPoints).ceil());
}

final _macro = RegExp(
  r'\$(?:\{__(rate_interval|interval_ms|interval|range_ms|range_s|range)\}|'
  r'__(rate_interval|interval_ms|interval|range_ms|range_s|range)(?![A-Za-z0-9_]))',
);

/// Expands Grafana's global macros: `$__interval`, `$__interval_ms`,
/// `$__rate_interval`, `$__range`, `$__range_s` and `$__range_ms`, also in
/// `${__name}` form. `$__rate_interval` is at least four scrape intervals
/// (15 s unless [scrapeIntervalSeconds] says otherwise), so `rate()` always
/// spans enough samples. Dashboard variables are not touched.
String expandMacros(
  String expression, {
  required int stepSeconds,
  required Duration range,
  int scrapeIntervalSeconds = 15,
}) {
  final rangeSeconds = (range.inMilliseconds / 1000).ceil();
  return expression.replaceAllMapped(_macro, (match) {
    return switch (match[1] ?? match[2]) {
      'rate_interval' =>
        '${math.max(stepSeconds + scrapeIntervalSeconds, 4 * scrapeIntervalSeconds)}s',
      'interval_ms' => '${stepSeconds * 1000}',
      'interval' => '${stepSeconds}s',
      'range_ms' => '${range.inMilliseconds}',
      'range_s' => '$rangeSeconds',
      _ => '${rangeSeconds}s',
    };
  });
}

/// Unix seconds with millisecond precision, as Prometheus accepts.
String unixSeconds(DateTime time) => (time.millisecondsSinceEpoch / 1000).toStringAsFixed(3);

/// Whole Unix seconds, as Tempo's search API expects.
String wholeUnixSeconds(DateTime time) => '${time.millisecondsSinceEpoch ~/ 1000}';

/// Unix nanoseconds, as Loki expects.
String unixNanos(DateTime time) => '${time.microsecondsSinceEpoch * 1000}';
