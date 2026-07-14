# hippobase_auth_models

Shared Hippobase Better Auth table row, insert, update, table, and JSON schema models.

Regenerate models with:

```sh
dart run tool/generate_models.dart
```

Or, if you use `just`:

```sh
just generate
```

Generated output remains grouped by schema and table under `lib/generated`.
The handwritten JSON-schema registry lives under `lib/src/schemas`.
