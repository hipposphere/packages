# Hippobase Auth API Contract

Platform-neutral request and response DTOs, JSON schemas, route paths, methods,
and operation IDs shared by `hippobase_auth_server` and
`hippobase_auth_client`.

The contract intentionally exposes the functional `/v1/user/*`,
`/v1/oauth2/*`, and `/v1/admin/*` operations. It contains no Better Auth
catch-all, passkey API, or placeholder OAuth-client CRUD routes.

The independently mounted admin API is resource-oriented:

- `POST /v1/admin/users` creates a user.
- `GET /v1/admin/users?offset=0&limit=50` returns `items` plus the shared
  Hippobase `PaginationMeta`.
- `PATCH /v1/admin/users/<userId>` updates the user's role.
- `DELETE /v1/admin/users/<userId>` deletes the user and its dependent auth
  data.

The list query is the reusable `PaginationConfig` from
`hippobase_core_models`; it is not a second auth-specific pagination model.

## Structure

Contracts are grouped by mounted router under `lib/src/user`,
`lib/src/oauth2`, and `lib/src/admin`. Every operation owns a handwritten
`.dart` contract using Dart Edge's HTTP-specific `@FromHttpSchema` annotation
and a sibling generated `.g.dart`. Schema definitions come directly from the
standalone `json_schema` package; `routes.dart` and `schemas.dart` only
aggregate those operation modules.
