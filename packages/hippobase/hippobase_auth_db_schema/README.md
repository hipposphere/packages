# hippobase_auth_db_schema

Shared Dart Edge SQL schema for the Better Auth-compatible Hippobase auth tables.

Each unchanged Better Auth table is declared in its own file under
`lib/src/auth/tables`; `auth/schema.dart` only assembles them in dependency
order.
