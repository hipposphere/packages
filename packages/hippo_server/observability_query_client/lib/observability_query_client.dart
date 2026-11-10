/// Read-only clients for Prometheus, Loki and Grafana Tempo over Dart HTTP's
/// `HttpClientTransport`. Parsing and request building live in
/// `observability_wire`, which is re-exported here.
library;

export 'package:observability_wire/observability_wire.dart';

export 'src/clients.dart';
export 'src/source.dart';
