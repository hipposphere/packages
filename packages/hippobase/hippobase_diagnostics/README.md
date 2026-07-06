# hippobase_diagnostics

Shared support-diagnostics primitives for Hippobase app and server runtimes.

This package owns the platform-neutral pieces:

- structured diagnostic log entries
- log levels and query filters
- redaction
- NDJSON encoding
- in-memory store for tests and fallback runtimes
- a small logger facade

Flutter capture/viewer code lives in `hippobase_diagnostics_flutter`. Dart Edge adapters live in
`hippobase_diagnostics_dart_edge`.
