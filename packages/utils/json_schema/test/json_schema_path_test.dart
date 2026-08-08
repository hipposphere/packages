import 'package:json_schema/json_schema.dart';
import 'package:test/test.dart';

void main() {
  const schema = JsonSchema.object(
    title: 'Root',
    properties: <String, JsonSchema>{
      'profile/name': JsonSchema.array(
        items: JsonSchema.anyOf(<JsonSchema>[
          JsonSchema.string(format: 'uuid'),
          JsonSchema.integer(),
        ]),
      ),
    },
  );

  group('JsonSchemaPath', () {
    test('reads typed schema relationships', () {
      final path = JsonSchemaPath.root.property('profile/name').items.anyOf(1);

      expect(path.read(schema), isA<JsonIntegerSchema>());
      expect(path.existsIn(schema), isTrue);
      expect(path.parent().read(schema), isA<JsonAnyOfSchema>());
      expect(JsonSchemaPath.root.property('missing').read(schema), isNull);
    });

    test('converts to an escaped pointer into the serialized schema', () {
      final path = JsonSchemaPath.root.property('profile/name').items.anyOf(0);

      expect(path.toJsonPointer(), JsonPointer('/properties/profile~1name/items/anyOf/0'));
      expect(path.toUriFragment(), '#/properties/profile~1name/items/anyOf/0');
      expect(path.toString(), '#/properties/profile~1name/items/anyOf/0');
      expect(path.toJsonPointer().read(schema.toJson()), {'type': 'string', 'format': 'uuid'});
    });

    test('has immutable value semantics', () {
      final first = JsonSchemaPath.root.property('profile/name').items;
      final second = JsonSchemaPath.root.property('profile/name').items;

      expect(first, second);
      expect(<JsonSchemaPath>{first, second}, hasLength(1));
      expect(() => first.steps.add(const JsonSchemaItemsStep()), throwsUnsupportedError);
      expect(const JsonSchemaPath.empty(), JsonSchemaPath.root);
    });

    test('rejects a composite keyword that does not match the schema', () {
      final anyOf = JsonSchemaPath.root.property('profile/name').items.anyOf(0);
      final oneOf = JsonSchemaPath.root.property('profile/name').items.oneOf(0);

      expect(anyOf.existsIn(schema), isTrue);
      expect(oneOf.existsIn(schema), isFalse);
    });

    test('rejects invalid composite branch steps', () {
      expect(() => JsonSchemaBranchStep('not', 0), throwsArgumentError);
      expect(() => JsonSchemaPath.root.anyOf(-1), throwsRangeError);
    });

    test('replaces a nested node without changing the original tree', () {
      final path = JsonSchemaPath.root.property('profile/name').items.anyOf(1);
      final updated = path.replace(schema, const JsonSchema.boolean(defaultValue: true));

      expect(path.read(schema), isA<JsonIntegerSchema>());
      expect(path.read(updated!), isA<JsonBooleanSchema>());
      expect(updated.title, 'Root');
      expect(path.replace(const JsonSchema.string(), const JsonSchema.boolean()), isNull);
    });
  });

  test('walkJsonSchema visits every typed child with its path', () {
    final nodes = walkJsonSchema(schema).toList();

    expect(nodes, hasLength(5));
    expect(nodes.first.path, JsonSchemaPath.root);
    expect(nodes.map((node) => node.path.toString()), <String>[
      '#',
      '#/properties/profile~1name',
      '#/properties/profile~1name/items',
      '#/properties/profile~1name/items/anyOf/0',
      '#/properties/profile~1name/items/anyOf/1',
    ]);
  });
}
