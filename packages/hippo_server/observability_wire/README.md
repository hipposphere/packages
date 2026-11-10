# observability_wire

Transport-independent wire contracts for the Prometheus, Loki and Grafana Tempo query APIs. Nothing here performs I/O and the package has no dependencies: request builders describe the HTTP calls, parsers turn the JSON answers into frames, and a client supplies the transport. Use [`observability_query_client`](../observability_query_client) for ready-made clients over Dart HTTP.

```dart
// Describe the call, send it with any transport, parse the answer.
final request = PrometheusRequests.queryRange(
  'sum by (route) (rate(http_requests_total[5m]))',
  start: from,
  end: to,
  stepSeconds: planStepSeconds(range: to.difference(from), maxPoints: 1000),
);
final uri = request.resolve(Uri.parse('https://prometheus.internal/')); // keeps a proxy prefix
final json = decodeUpstreamJson(statusCode: status, body: body, secrets: [token]);
final result = normalizeMetricData(envelopeData(json), evaluatedAt: to, maxSeries: 500);
```

## What it holds

- **Requests:** `PrometheusRequests`, `LokiRequests`, `TempoRequests` (query, range, labels, search, traces, tags).
- **Frames:** `WireFrame`, `WireField`, `WireLabel`, `WireResult`, `WireSpan`. A Prometheus or Loki metric result is one wide time series frame (a `time` field over the union of timestamps, one `number` field per series, null for missing or non-finite values); Loki streams are one `logs` frame each; a Tempo search is a `table`; a trace is a list of spans.
- **Parsers:** `normalizeMetricData`, `normalizeLokiStreams`, `normalizeTempoSearch`, `parseTempoTrace` (OTLP JSON, v1 and v2, hex or base64 ids), `parseTempoTags`, `normalizeTraceId`.
- **Planning:** `planStepSeconds`, `expandMacros` (`$__interval`, `$__rate_interval`, `$__range` and friends), and the time formats of each API.
- **Errors:** `decodeUpstreamJson` keeps the backend's own error text, `redactText` removes URLs and credentials from messages.

## Not here

Credentials, limits, retries and transport live in the client. Dashboard variables and legends beyond `{{label}}` are the application's.
