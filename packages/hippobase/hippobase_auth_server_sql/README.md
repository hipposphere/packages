# Hippobase Auth Server SQL

Dart Edge SQL implementation of `HippobaseAuthStore`. This package owns auth
queries and transaction boundaries and is the only Hippobase Auth package that
depends on the native Dart Edge SQL runtime.

```dart
final store = HippobaseAuthSqlStore(database, schema: 'auth');
```
