# hippobase_core_server

Server-side adapters for applying `hippobase_core_models` list queries to
typed `dart_edge_sql` select queries.

The package requires explicit field mapping. Client-provided field names are
never treated as raw SQL column names.

```dart
final spec = QuerySpec(
  fields: {
    'email': QueryField.text(users.email),
    'created_at': QueryField.dateTime(users.createdAt),
  },
);

final rows = await executor.typed
    .from(users)
    .applyListQuery(query, spec)
    .select([users.id, users.email])
    .execute();
```
