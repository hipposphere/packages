# hippobase_core_models

Shared Hippobase pagination, sorting, and filtering query models.

The package is intentionally transport-only: it models list query intent and
pagination metadata, but does not depend on SQL builders or Truhnlab packages.
Schema-backed models are generated from const `JsonSchema` definitions with
`@FromSchema`, so projects can reuse the same Dart models and JSON Schemas.
Serialized JSON/schema property names use `snake_case`; Dart fields remain
idiomatic `camelCase`.
Servers should translate `ListQuery` into database predicates through a
whitelisted field mapping.

```dart
final query = ListQuery(
  pagination: paginationConfig(offset: 0, limit: 25),
  sort: [SortTerm(field: 'createdAt', direction: SortDirection.desc)],
  filter: andFilterGroup([
    fieldFilter('status', FilterOperator.eq, 'active'),
    fieldFilter('age', FilterOperator.gte, 18),
    fieldFilter('email', FilterOperator.ilike, '%@hippolabs.org'),
  ]),
);
```
