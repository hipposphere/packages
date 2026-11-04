import 'package:json_schema/json_schema.dart';

import 'stream_lines.dart';

part 'unions.g.dart';

/// Variants live in another library; their tags are inferred from the
/// single-value `type` enums of the referenced `@FromSchema` models.
const streamLineSchema = JsonSchema.oneOf(
  <JsonSchema>[
    JsonSchema.componentRef('PhaseLine'),
    JsonSchema.componentRef('KeepaliveLine'),
    JsonSchema.componentRef('ResultLine'),
  ],
  id: 'StreamLine',
  discriminator: JsonDiscriminator(propertyName: 'type'),
);

@FromSchema(streamLineSchema)
typedef StreamLine = _$StreamLine;

const tolerantStreamLineSchema = JsonSchema.oneOf(
  <JsonSchema>[JsonSchema.componentRef('PhaseLine'), JsonSchema.componentRef('KeepaliveLine')],
  id: 'TolerantStreamLine',
  discriminator: JsonDiscriminator(
    propertyName: 'type',
    mapping: <String, String>{'phase': 'PhaseLine', 'keepalive': 'KeepaliveLine'},
  ),
);

@FromSchema(tolerantStreamLineSchema, unknownVariant: true)
typedef TolerantStreamLine = _$TolerantStreamLine;

/// Pydantic emits boolean discriminators with Python spelling in `mapping`.
const roleSchema = JsonSchema.oneOf(
  <JsonSchema>[JsonSchema.componentRef('RolePresent'), JsonSchema.componentRef('RoleAbsent')],
  id: 'Role',
  discriminator: JsonDiscriminator(
    propertyName: 'configured',
    mapping: <String, String>{
      'True': '#/components/schemas/RolePresent',
      'False': '#/components/schemas/RoleAbsent',
    },
  ),
);

@FromSchema(roleSchema)
typedef Role = _$Role;

const envelopeSchema = JsonSchema.object(
  id: 'Envelope',
  properties: <String, JsonSchema>{
    'line': JsonSchema.componentRef('StreamLine'),
    'lines': JsonSchema.array(items: JsonSchema.componentRef('StreamLine')),
    'previous': JsonSchema.anyOf(<JsonSchema>[
      JsonSchema.componentRef('StreamLine'),
      JsonSchema.nullType(),
    ]),
    'role': JsonSchema.oneOf(<JsonSchema>[
      JsonSchema.componentRef('RolePresent'),
      JsonSchema.componentRef('RoleAbsent'),
    ], discriminator: JsonDiscriminator(propertyName: 'configured')),
    'roles': JsonSchema.array(
      items: JsonSchema.oneOf(<JsonSchema>[
        JsonSchema.componentRef('RolePresent'),
        JsonSchema.componentRef('RoleAbsent'),
      ], discriminator: JsonDiscriminator(propertyName: 'configured')),
    ),
    'keepalive': JsonSchema.anyOf(<JsonSchema>[
      JsonSchema.componentRef('KeepaliveLine'),
      JsonSchema.nullType(),
    ]),
    'note': JsonSchema.anyOf(<JsonSchema>[JsonSchema.string(), JsonSchema.nullType()]),
    'detail': JsonSchema.anyOf(<JsonSchema>[
      JsonSchema.componentRef('PhaseLine'),
      JsonSchema.componentRef('KeepaliveLine'),
    ]),
  },
  required: <String>['line', 'lines', 'previous', 'role', 'roles', 'keepalive', 'note'],
);

@FromSchema(envelopeSchema)
typedef Envelope = _$Envelope;
