# json_schema_gen

Generates plain Dart JSON models from portable `@FromSchema` annotations.

```dart
import 'package:json_schema/json_schema.dart';

part 'user.g.dart';

const userSchema = JsonSchema.object(
  id: 'User',
  properties: {'id': JsonSchema.string()},
  required: ['id'],
);

@FromSchema(userSchema)
typedef User = _$User;
```

Add `json_schema_gen` and `build_runner` to the consuming package, then run
`dart run build_runner build`. Generated models expose schema constants plus
`fromJson`, `decode`, and `toJson`, and implement `JsonEncodable` without
importing Dart Edge packages.

## Discriminated unions

A `@FromSchema` `oneOf` (or `anyOf`) with a `JsonDiscriminator` whose branches
are `componentRef`s to other `@FromSchema` object models generates a sealed
union:

```dart
// stream_lines.dart
const phaseLineSchema = JsonSchema.object(
  id: 'PhaseLine',
  properties: {
    'type': JsonSchema.string(enumValues: ['phase']),
    'phase': JsonSchema.string(),
  },
  required: ['type', 'phase'],
);

@FromSchema(phaseLineSchema)
typedef PhaseLine = _$PhaseLine;

// KeepaliveLine is declared the same way with `enumValues: ['keepalive']`.

// stream_line.dart
const streamLineSchema = JsonSchema.oneOf(
  [JsonSchema.componentRef('PhaseLine'), JsonSchema.componentRef('KeepaliveLine')],
  id: 'StreamLine',
  discriminator: JsonDiscriminator(propertyName: 'type'),
);

@FromSchema(streamLineSchema, unknownVariant: true)
typedef StreamLine = _$StreamLine;
```

The generator emits `sealed class _$StreamLine` with `fromJson`, `decode`,
`toJson`, the schema constants, and one `final class` wrapper per branch.
Wrappers are named after their string tag (`StreamLine$Phase`) or, for boolean
and numeric tags, after the wrapped type (`Role$RolePresent`). Each wrapper
holds the variant model in `value`:

```dart
final line = StreamLine.fromJson(json);
final text = switch (line) {
  StreamLine$Phase(:final value) => 'phase ${value.phase}',
  StreamLine$Keepalive() => 'keepalive',
  StreamLine$Unknown(:final discriminatorValue) => 'unknown $discriminatorValue',
};
```

The base wraps variants instead of having variant models implement it because
Dart only allows direct subtypes of a sealed class in the declaring library,
while variant models are ordinary typedefs that may live in other files or
libraries and may belong to several unions.

- Tags come from `JsonDiscriminator.mapping` and from branches whose schema pins
  the discriminator property to one enum value. The generator reads branch
  schemas from the annotation's `registry` or from the `@FromSchema` typedef
  visible under the referenced type name. A string `mapping` key that
  contradicts a branch's pinned value is an error; non-string pinned values
  (Pydantic's `"True"`/`"False"` keys for booleans) are matched by JSON value.
- Unknown or missing tags throw a `FormatException`. With
  `unknownVariant: true`, they decode into `StreamLine$Unknown`, which keeps
  the raw JSON for `toJson`, so streaming clients stay forward compatible.
- Properties and list items referencing the union (`componentRef('StreamLine')`)
  use the sealed type. A discriminated union declared inline in a property
  generates a union named after the owner and property, for example
  `EnvelopeRole` or `EnvelopeRolesItem` for list items.
- The re-emitted `schema` constant keeps every branch and the discriminator,
  with inferred string tags added to `mapping`.
- `anyOf`/`oneOf` without a discriminator keeps the `Object?` type unless a
  `dartType` is provided.

## Nullable composites

An `anyOf` or `oneOf` of exactly one non-null schema plus
`JsonSchema.nullType()` generates that schema's Dart type as nullable. A
nullable reference such as
`JsonSchema.anyOf([JsonSchema.componentRef('User'), JsonSchema.nullType()])`
becomes `User?`, decoded as `null` or `User.decode(...)` and encoded with
`?.toJson()`. The emitted schema keeps the original `anyOf`.

## Formatting

Generated Dart defaults to the shared `hippo_analysis` formatting policy.
Consumers can still override `page_width` or `trailing_commas` in their builder
options when they intentionally use a different policy.
