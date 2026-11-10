# Hippo Server

Reusable server-side packages for Hipposphere applications.

- `observability_wire`: transport-independent request builders, parsers and
  frames for the Prometheus, Loki, and Tempo query APIs.
- `observability_query_client`: read-only Prometheus, Loki, and Tempo clients
  over Dart HTTP's transport interface, built on `observability_wire`.
- `docker_engine_client`: typed Docker Engine HTTP API access, including image
  pulls and container creation and lifecycle operations.
- `docker_compose_client`: typed, shell-free Docker Compose project operations.
- `linux_host_inspector`: read-only Linux host and process inspection.
- `systemd_client`: typed systemd discovery, events, and lifecycle operations.
