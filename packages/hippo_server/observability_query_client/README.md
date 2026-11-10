# observability_query_client

Read-only clients for Prometheus, Loki and Grafana Tempo over Dart HTTP's `HttpClientTransport` (`dart_http_core`). Request building and response parsing live in [`observability_wire`](../observability_wire), which this package re-exports, so a client works wherever a Dart HTTP transport does.

```dart
final source = ObservabilitySource(
  baseUri: Uri.parse('http://prometheus.internal:9090'),
  transport: DartHttpClientTransport(), // any HttpClientTransport
  bearerToken: serverHeldToken,
);
final prometheus = PrometheusClient(source);

final range = end.difference(start);
final step = planStepSeconds(range: range, maxPoints: 1000);
final result = await prometheus.queryRange(
  expandMacros(r'sum(rate(http_requests_total[$__rate_interval]))', stepSeconds: step, range: range),
  start: start,
  end: end,
  stepSeconds: step,
);
```

`LokiClient` runs LogQL (log streams and metric queries), `TempoClient` runs TraceQL search, loads a trace by id (v2 route, then v1 for Tempo before 2.5) and lists tags. Results are `WireResult` frames and `WireSpan`s.

## Safety

Every call refuses redirects, so credentials never reach another host; stops reading a response past `maxResponseBytes` (16 MiB by default) and aborts the request; gives up after `timeout`; and reports failures as `ObservabilityUpstreamException` without the source's URL, host or credentials. A backend's own error text (a PromQL syntax error, say) is kept, since that is what fixes a query.

The package deliberately has no authorization, user-facing limits or proxy API: keep credentials server-side and apply your own access policy first.

## From 0.1

0.2.0 replaces `package:http` with `HttpClientTransport` and the per-API result models with `observability_wire` frames. `ObservabilityHttpClient` is gone; build an `ObservabilitySource`.
