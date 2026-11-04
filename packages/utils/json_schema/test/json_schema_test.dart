import 'package:json_schema/json_schema.dart';
import 'package:test/test.dart';

void main() {
  test('JsonSchema implements JsonEncodable', () {
    const schema = JsonSchema.string();

    expect(schema, isA<JsonEncodable>());
  });

  test('serializes id as JSON Schema \$id', () {
    expect(
      const JsonSchema.object(
        id: 'UserDto',
        properties: <String, JsonSchema>{'id': JsonSchema.string()},
      ).toJson(),
      {
        r'$id': 'UserDto',
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
        },
      },
    );
  });

  test('keeps JSON Schema \$ref separate from \$id', () {
    expect(const JsonSchema.ref('#/components/schemas/UserDto', id: 'UserDtoReference').toJson(), {
      r'$id': 'UserDtoReference',
      r'$ref': '#/components/schemas/UserDto',
    });
  });

  test('component refs serialize as JSON Schema component refs', () {
    expect(const JsonSchema.componentRef('UserDto', id: 'UserDtoReference').toJson(), {
      r'$id': 'UserDtoReference',
      r'$ref': '#/components/schemas/UserDto',
    });
  });

  test('serializes enum as JSON Schema enum keyword', () {
    expect(const JsonSchema.string(enumValues: <Object?>['draft', 'published', null]).toJson(), {
      'enum': ['draft', 'published', null],
      'type': 'string',
    });
  });

  test('serializes inclusive integer bounds', () {
    const schema = JsonSchema.integer(minimum: 0, maximum: 100);

    expect(schema, isA<JsonIntegerSchema>());
    expect((schema as JsonIntegerSchema).minimum, 0);
    expect(schema.maximum, 100);
    expect(schema.toJson(), {'type': 'integer', 'minimum': 0, 'maximum': 100});
  });

  test('serializes inclusive number bounds', () {
    const schema = JsonSchema.number(minimum: -1.5, maximum: 2.75);

    expect(schema, isA<JsonNumberSchema>());
    expect((schema as JsonNumberSchema).minimum, -1.5);
    expect(schema.maximum, 2.75);
    expect(schema.toJson(), {'type': 'number', 'minimum': -1.5, 'maximum': 2.75});
  });

  test('serializes primitive JSON Schema default annotations', () {
    expect(const JsonSchema.string(defaultValue: 'draft').toJson(), {
      'type': 'string',
      'default': 'draft',
    });
    expect(const JsonSchema.integer(defaultValue: 10).toJson(), {'type': 'integer', 'default': 10});
    expect(const JsonSchema.number(defaultValue: 1.5).toJson(), {'type': 'number', 'default': 1.5});
    expect(const JsonSchema.boolean(defaultValue: false).toJson(), {
      'type': 'boolean',
      'default': false,
    });
  });

  test('keeps Dart string type metadata out of JSON Schema output', () {
    const schema = JsonStringSchema(format: 'uuid', dartType: DartSchemaType.parameter('TId'));

    expect(schema.dartType, isA<DartGenericSchemaType>());
    expect(schema.toJson(), {'type': 'string', 'format': 'uuid'});
  });

  test('supports named Dart string type metadata', () {
    const schema = JsonSchema.string(format: 'uuid', dartType: DartSchemaType.named('WorkspaceId'));

    expect(schema, isA<JsonStringSchema>());
    expect((schema as JsonStringSchema).dartType, isA<DartNamedSchemaType>());
    expect(schema.toJson(), {'type': 'string', 'format': 'uuid'});
  });

  test('distinguishes Dart value and model conversions', () {
    const valueSchema = JsonSchema.string(dartType: DartSchemaType.value('WorkspaceId'));
    const modelSchema = JsonSchema.string(dartType: DartSchemaType.model('WorkspaceId'));

    expect(
      (valueSchema as JsonStringSchema).dartType,
      isA<DartNamedSchemaType>().having(
        (type) => type.conversion,
        'conversion',
        DartSchemaConversion.value,
      ),
    );
    expect(
      (modelSchema as JsonStringSchema).dartType,
      isA<DartNamedSchemaType>().having(
        (type) => type.conversion,
        'conversion',
        DartSchemaConversion.model,
      ),
    );
    expect(valueSchema.toJson(), {'type': 'string'});
    expect(modelSchema.toJson(), {'type': 'string'});
  });

  test('serializes anyOf schemas and keeps Dart type metadata out of output', () {
    const schema = JsonSchema.anyOf([
      JsonSchema.string(),
      JsonSchema.array(items: JsonSchema.string()),
    ], dartType: DartSchemaType.model('RoleInput'));

    expect(schema, isA<JsonAnyOfSchema>());
    expect(
      (schema as JsonAnyOfSchema).dartType,
      isA<DartNamedSchemaType>().having(
        (type) => type.conversion,
        'conversion',
        DartSchemaConversion.model,
      ),
    );
    expect(schema.toJson(), {
      'anyOf': [
        {'type': 'string'},
        {
          'type': 'array',
          'items': {'type': 'string'},
        },
      ],
    });
  });

  test('reads id from raw schemas', () {
    const schema = JsonSchema.raw({r'$id': 'RawUser', 'type': 'object'});

    expect(schema.id, 'RawUser');
    expect(schema.toJson(), {r'$id': 'RawUser', 'type': 'object'});
  });

  test('reads enum from raw schemas', () {
    const schema = JsonSchema.raw({
      'type': 'string',
      'enum': ['draft', 'published'],
    });

    expect(schema.enumValues, ['draft', 'published']);
    expect(schema.toJson(), {
      'type': 'string',
      'enum': ['draft', 'published'],
    });
  });

  test('copyWith preserves subtype and unchanged values', () {
    const schema = JsonStringSchema(
      id: 'Identifier',
      title: 'Old title',
      nullable: true,
      format: 'uuid',
      dartType: DartSchemaType.value('Identifier'),
    );

    final copied = schema.copyWith(title: 'New title', enumValues: <Object?>['known']);

    expect(copied, isA<JsonStringSchema>());
    expect(copied.id, 'Identifier');
    expect(copied.title, 'New title');
    expect(copied.nullable, isTrue);
    expect(copied.format, 'uuid');
    expect(copied.dartType, same(schema.dartType));
    expect(copied.enumValues, ['known']);
  });

  test('subtype copyWith updates structural values', () {
    const schema = JsonObjectSchema(
      properties: <String, JsonSchema>{'old': JsonSchema.string()},
      required: <String>['old'],
      additionalProperties: true,
    );

    final copied = schema.copyWith(
      properties: const <String, JsonSchema>{'new': JsonSchema.integer()},
      required: const <String>['new'],
      additionalProperties: false,
    );

    expect(copied.properties, contains('new'));
    expect(copied.required, ['new']);
    expect(copied.additionalProperties, isFalse);
  });

  test('composite copyWith preserves its concrete keyword', () {
    const schema = JsonSchema.oneOf(<JsonSchema>[JsonSchema.string()]);

    final copied = (schema as JsonOneOfSchema).copyWith(
      schemas: const <JsonSchema>[JsonSchema.boolean()],
      nullable: true,
    );

    expect(copied, isA<JsonOneOfSchema>());
    expect(copied.schemas.single, isA<JsonBooleanSchema>());
    expect(copied.toJson(), {
      'oneOf': [
        {'type': 'boolean'},
      ],
      'nullable': true,
    });
  });

  group('discriminator', () {
    const phaseLine = JsonSchema.object(
      id: 'PhaseLine',
      properties: <String, JsonSchema>{
        'type': JsonSchema.string(enumValues: <Object?>['phase']),
        'phase': JsonSchema.string(),
      },
      required: <String>['type', 'phase'],
    );
    const keepaliveLine = JsonSchema.object(
      id: 'KeepaliveLine',
      properties: <String, JsonSchema>{
        'type': JsonSchema.string(enumValues: <Object?>['keepalive']),
      },
      required: <String>['type'],
    );

    test('serializes an explicit mapping as OpenAPI component references', () {
      const schema = JsonSchema.oneOf(
        <JsonSchema>[
          JsonSchema.componentRef('PhaseLine'),
          JsonSchema.componentRef('KeepaliveLine'),
        ],
        discriminator: JsonDiscriminator(
          propertyName: 'type',
          mapping: <String, String>{
            'phase': 'PhaseLine',
            'keepalive': '#/components/schemas/KeepaliveLine',
          },
        ),
      );

      expect(schema.toJson(), {
        'oneOf': [
          {r'$ref': '#/components/schemas/PhaseLine'},
          {r'$ref': '#/components/schemas/KeepaliveLine'},
        ],
        'discriminator': {
          'propertyName': 'type',
          'mapping': {
            'phase': '#/components/schemas/PhaseLine',
            'keepalive': '#/components/schemas/KeepaliveLine',
          },
        },
      });
    });

    test('omits an empty mapping', () {
      const schema = JsonSchema.anyOf(<JsonSchema>[
        JsonSchema.componentRef('PhaseLine'),
      ], discriminator: JsonDiscriminator(propertyName: 'type'));

      expect(schema.toJson()['discriminator'], {'propertyName': 'type'});
    });

    test('infers missing mapping entries from single-value branch properties', () {
      const discriminator = JsonDiscriminator(
        propertyName: 'type',
        mapping: <String, String>{'beat': 'KeepaliveLine'},
      );
      final schemas = <String, JsonSchema>{'PhaseLine': phaseLine, 'KeepaliveLine': keepaliveLine};

      expect(
        discriminator.resolveMapping(const <JsonSchema>[
          JsonSchema.componentRef('PhaseLine'),
          JsonSchema.componentRef('KeepaliveLine'),
          JsonSchema.componentRef('Missing'),
        ], lookup: (id) => schemas[id]),
        {'beat': 'KeepaliveLine', 'phase': 'PhaseLine'},
      );
      expect(discriminator.valueOf(phaseLine), 'phase');
      expect(discriminator.valueOf(const JsonSchema.string()), isNull);
    });

    test('registry serialization completes inferred mappings', () {
      const registry = JsonSchemaRegistry(
        schemas: <JsonSchema>[
          phaseLine,
          keepaliveLine,
          JsonSchema.oneOf(
            <JsonSchema>[
              JsonSchema.componentRef('PhaseLine'),
              JsonSchema.componentRef('KeepaliveLine'),
            ],
            id: 'StreamLine',
            discriminator: JsonDiscriminator(propertyName: 'type'),
          ),
        ],
      );

      expect(registry.asMap()['StreamLine']?['discriminator'], {
        'propertyName': 'type',
        'mapping': {
          'phase': '#/components/schemas/PhaseLine',
          'keepalive': '#/components/schemas/KeepaliveLine',
        },
      });
    });

    test('copyWith keeps the discriminator', () {
      const schema = JsonSchema.oneOf(<JsonSchema>[
        JsonSchema.componentRef('PhaseLine'),
      ], discriminator: JsonDiscriminator(propertyName: 'type'));

      final copied = (schema as JsonOneOfSchema).copyWith(nullable: true);

      expect(copied.discriminator?.propertyName, 'type');
    });

    test('reference helpers distinguish ids from references', () {
      expect(JsonDiscriminator.referenceFor('PhaseLine'), '#/components/schemas/PhaseLine');
      expect(JsonDiscriminator.referenceFor('other.json#/Line'), 'other.json#/Line');
      expect(JsonDiscriminator.schemaIdFor('#/components/schemas/PhaseLine'), 'PhaseLine');
      expect(JsonDiscriminator.schemaIdFor('PhaseLine'), 'PhaseLine');
      expect(JsonDiscriminator.schemaIdFor('#/definitions/PhaseLine'), isNull);
    });
  });

  test('null type serializes as JSON Schema null', () {
    const schema = JsonSchema.nullType(description: 'Nothing');

    expect(schema, isA<JsonNullSchema>());
    expect(schema.nullable, isTrue);
    expect(schema.toJson(), {'description': 'Nothing', 'type': 'null'});
    expect(
      const JsonSchema.anyOf(<JsonSchema>[JsonSchema.componentRef('User'), JsonSchema.nullType()])
          .toJson(),
      {
        'anyOf': [
          {r'$ref': '#/components/schemas/User'},
          {'type': 'null'},
        ],
      },
    );
  });
}
