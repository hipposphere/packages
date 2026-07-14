# json_schema

Typed, const-friendly Dart contracts for a practical subset of JSON Schema.

```dart
import 'package:json_schema/json_schema.dart';

const user = JsonSchema.object(
  id: 'User',
  properties: {'id': JsonSchema.string()},
  required: ['id'],
);
```

Use `JsonSchemaRegistry` to collect addressable schemas and `JsonSchema.ref`
or `JsonSchema.componentRef` to reuse definitions. For Dart model generation,
pair this package with `json_schema_gen`.
