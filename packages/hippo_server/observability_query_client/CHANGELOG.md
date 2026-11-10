# Changelog

## 0.2.1

- Redact the source's URL and credentials from backend warnings, which were passed on as notices unchanged.

## 0.2.0

- Breaking: clients run over Dart HTTP's `HttpClientTransport` instead of `package:http`; `ObservabilityHttpClient` is replaced by `ObservabilitySource`.
- Breaking: results are `observability_wire` frames and spans (wide time series, log streams, trace tables, spans) instead of per-API models.
- Refuse redirects, cap response size and abort the request, apply a timeout, and keep URLs and credentials out of errors.
- Add Tempo trace lookup with the v1 fallback, TraceQL search and tag lookups; Loki metric queries; Prometheus instant and range queries.

## 0.1.0

- First release with `package:http` based Prometheus, Loki and Tempo clients.
