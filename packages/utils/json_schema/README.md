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
pair this package with `json_schema_gen`. `JsonSchema` and generated JSON model
objects implement `JsonEncodable`, the shared contract for values exposing a
JSON-friendly `toJson()` representation.

## JSON Pointer

`JsonPointer` parses and serializes the RFC 6901 string representation and can
resolve pointers against decoded JSON values:

```dart
final document = <String, Object?>{
  'users': <Object?>[
    <String, Object?>{'name': 'Ada'},
  ],
};
final pointer = JsonPointer('/users/0/name');

print(pointer.read(document)); // Ada
print(pointer.child('first/last')); // /users/0/name/first~1last
```

Use `existsIn` when JSON `null` must be distinguished from a missing location.
The root pointer is available as `JsonPointer.root` or
`const JsonPointer.empty()`. URI fragment identifiers such as `#/users/0` are
not accepted. `JsonPointer.schema` exposes the corresponding JSON Schema for
registries and generated API contracts.

## Schema paths

`JsonSchemaPath` navigates the typed schema tree and converts to a JSON Pointer
into the serialized schema document:

```dart
final path = JsonSchemaPath.root.property('id');
final idSchema = path.read(user);

print(path.toJsonPointer()); // /properties/id
print(path.toUriFragment()); // #/properties/id
```

Paths also support immutable node replacement. `walkJsonSchema` visits the
root and every typed property, item schema, and composition branch.

Every concrete schema provides a subtype-preserving `copyWith`. A `null`
argument keeps the existing value; use a constructor when a nullable field
must be cleared explicitly.
