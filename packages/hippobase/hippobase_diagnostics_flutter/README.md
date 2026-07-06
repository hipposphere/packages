# hippobase_diagnostics_flutter

Flutter capture, storage, export, and viewer helpers for `hippobase_diagnostics`.

The package provides:

- app-local rotating NDJSON log storage on native platforms
- in-memory fallback storage on non-IO platforms
- `runZoned` bootstrap helpers for print/error capture
- a controller for project-specific log viewer UIs
- explicit NDJSON export through `file_selector` when supported
