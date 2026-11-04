## 0.2.0

- Add `JsonDiscriminator` for `JsonSchema.oneOf` and `JsonSchema.anyOf`,
  serialized as the OpenAPI `discriminator` keyword with
  `#/components/schemas/...` mapping references. Mappings can be inferred from
  branches that pin the discriminator property to a single enum value, and
  `JsonSchemaRegistry.asMap` completes them from the registry.
- Add `JsonSchema.nullType()` (`JsonNullSchema`), serialized as
  `{"type": "null"}`. Breaking: exhaustive `switch`es over the sealed
  `JsonSchema` hierarchy need a `JsonNullSchema` case.
- Add `FromSchema.unknownVariant` for generated discriminated unions.

## 0.1.5

- Add typed `JsonSchemaPath` traversal, serialized JSON Pointer conversion,
  immutable node replacement, and depth-first schema walking.
- Add subtype-preserving `copyWith` methods to JSON Schema values.

## 0.1.4

- Add an immutable RFC 6901 `JsonPointer`, decoded JSON lookup helpers, and a
  reusable JSON Schema contract.

## 0.1.2

- Add typed JSON Schema `default` annotations for strings, integers, numbers,
  and booleans.

## 0.1.1

- Own the shared `JsonEncodable` contract and implement it on `JsonSchema`.

## 0.1.0

- Extract typed JSON Schema contracts, registries, references, and the portable
  `@FromSchema` annotation from Dart Edge.
