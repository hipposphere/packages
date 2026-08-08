import 'json_pointer.dart';
import 'json_schema.dart';

/// A typed step through a [JsonSchema] tree.
sealed class JsonSchemaPathStep {
  const JsonSchemaPathStep();
}

/// Selects a named property from a [JsonObjectSchema].
final class JsonSchemaPropertyStep extends JsonSchemaPathStep {
  /// Creates a property step for [name].
  const JsonSchemaPropertyStep(this.name);

  /// JSON property name.
  final String name;

  @override
  bool operator ==(Object other) => other is JsonSchemaPropertyStep && name == other.name;

  @override
  int get hashCode => Object.hash(JsonSchemaPropertyStep, name);
}

/// Selects the item schema from a [JsonArraySchema].
final class JsonSchemaItemsStep extends JsonSchemaPathStep {
  /// Creates an array-items step.
  const JsonSchemaItemsStep();

  @override
  bool operator ==(Object other) => other is JsonSchemaItemsStep;

  @override
  int get hashCode => 0x4a534953;
}

/// Selects one branch from a [JsonCompositeSchema].
final class JsonSchemaBranchStep extends JsonSchemaPathStep {
  /// Creates a composite branch step.
  factory JsonSchemaBranchStep(String keyword, int index) {
    if (keyword != 'anyOf' && keyword != 'oneOf' && keyword != 'allOf') {
      throw ArgumentError.value(keyword, 'keyword', 'Must be anyOf, oneOf, or allOf.');
    }
    RangeError.checkNotNegative(index, 'index');
    return JsonSchemaBranchStep._(keyword, index);
  }

  const JsonSchemaBranchStep._(this.keyword, this.index);

  /// JSON Schema composition keyword.
  final String keyword;

  /// Zero-based branch index.
  final int index;

  @override
  bool operator ==(Object other) =>
      other is JsonSchemaBranchStep && keyword == other.keyword && index == other.index;

  @override
  int get hashCode => Object.hash(JsonSchemaBranchStep, keyword, index);
}

/// An immutable location in the typed [JsonSchema] tree.
///
/// Unlike [JsonPointer], this path describes typed schema relationships. For
/// example, `JsonSchemaPath.root.property('name')` serializes to the schema
/// document pointer `/properties/name`, not the instance pointer `/name`.
final class JsonSchemaPath {
  JsonSchemaPath._(Iterable<JsonSchemaPathStep> steps)
    : steps = List<JsonSchemaPathStep>.unmodifiable(steps);

  /// The root schema path.
  const JsonSchemaPath.empty() : steps = const <JsonSchemaPathStep>[];

  /// The root schema path.
  static const root = JsonSchemaPath.empty();

  /// Typed traversal steps from the root schema.
  final List<JsonSchemaPathStep> steps;

  /// Whether this path addresses the root schema.
  bool get isRoot => steps.isEmpty;

  /// Returns a path selecting object property [name].
  JsonSchemaPath property(String name) =>
      JsonSchemaPath._(<JsonSchemaPathStep>[...steps, JsonSchemaPropertyStep(name)]);

  /// Returns a path selecting an array's item schema.
  JsonSchemaPath get items =>
      JsonSchemaPath._(<JsonSchemaPathStep>[...steps, const JsonSchemaItemsStep()]);

  /// Returns a path selecting branch [index] from an `anyOf` schema.
  JsonSchemaPath anyOf(int index) =>
      JsonSchemaPath._(<JsonSchemaPathStep>[...steps, JsonSchemaBranchStep('anyOf', index)]);

  /// Returns a path selecting branch [index] from a `oneOf` schema.
  JsonSchemaPath oneOf(int index) =>
      JsonSchemaPath._(<JsonSchemaPathStep>[...steps, JsonSchemaBranchStep('oneOf', index)]);

  /// Returns a path selecting branch [index] from an `allOf` schema.
  JsonSchemaPath allOf(int index) =>
      JsonSchemaPath._(<JsonSchemaPathStep>[...steps, JsonSchemaBranchStep('allOf', index)]);

  /// Returns this path without its final step.
  ///
  /// The root path is its own parent.
  JsonSchemaPath parent() => isRoot ? this : JsonSchemaPath._(steps.take(steps.length - 1));

  /// Reads the schema addressed by this path from [schema].
  ///
  /// Returns `null` when a step is incompatible with the current schema or a
  /// selected property, item schema, or composite branch does not exist.
  JsonSchema? read(JsonSchema schema) {
    var current = schema;
    for (final step in steps) {
      final next = _childAt(current, step);
      if (next == null) return null;
      current = next;
    }
    return current;
  }

  /// Whether this path resolves within [schema].
  bool existsIn(JsonSchema schema) => read(schema) != null;

  /// Returns [schema] with the addressed node replaced by [replacement].
  ///
  /// Returns `null` when this path does not resolve. Neither the original tree
  /// nor this path is mutated.
  JsonSchema? replace(JsonSchema schema, JsonSchema replacement) =>
      _replaceAt(schema, steps, 0, replacement);

  /// Converts this typed path to a pointer into [JsonSchema.toJson] output.
  JsonPointer toJsonPointer() {
    var pointer = JsonPointer.root;
    for (final step in steps) {
      switch (step) {
        case JsonSchemaPropertyStep(:final name):
          pointer = pointer.child('properties').child(name);
        case JsonSchemaItemsStep():
          pointer = pointer.child('items');
        case JsonSchemaBranchStep(:final keyword, :final index):
          pointer = pointer.child(keyword).child('$index');
      }
    }
    return pointer;
  }

  /// URI fragment identifying this path in a serialized schema document.
  String toUriFragment() => '#${toJsonPointer()}';

  @override
  String toString() => toUriFragment();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JsonSchemaPath || steps.length != other.steps.length) return false;
    for (var index = 0; index < steps.length; index++) {
      if (steps[index] != other.steps[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(steps);
}

/// A schema and its typed path, as returned by [walkJsonSchema].
final class JsonSchemaNode {
  /// Creates a visited schema node.
  const JsonSchemaNode({required this.path, required this.schema});

  /// Location of [schema] in the walked tree.
  final JsonSchemaPath path;

  /// Schema at [path].
  final JsonSchema schema;
}

/// Walks [schema] depth-first, starting with the root node.
Iterable<JsonSchemaNode> walkJsonSchema(JsonSchema schema) sync* {
  yield* _walk(schema, JsonSchemaPath.root);
}

Iterable<JsonSchemaNode> _walk(JsonSchema schema, JsonSchemaPath path) sync* {
  yield JsonSchemaNode(path: path, schema: schema);
  switch (schema) {
    case JsonObjectSchema(:final properties):
      for (final entry in properties.entries) {
        yield* _walk(entry.value, path.property(entry.key));
      }
    case JsonArraySchema(items: final items?):
      yield* _walk(items, path.items);
    case JsonAnyOfSchema(:final schemas):
      for (var index = 0; index < schemas.length; index++) {
        yield* _walk(schemas[index], path.anyOf(index));
      }
    case JsonOneOfSchema(:final schemas):
      for (var index = 0; index < schemas.length; index++) {
        yield* _walk(schemas[index], path.oneOf(index));
      }
    case JsonAllOfSchema(:final schemas):
      for (var index = 0; index < schemas.length; index++) {
        yield* _walk(schemas[index], path.allOf(index));
      }
    default:
      return;
  }
}

JsonSchema? _childAt(JsonSchema schema, JsonSchemaPathStep step) => switch ((schema, step)) {
  (JsonObjectSchema(:final properties), JsonSchemaPropertyStep(:final name)) => properties[name],
  (JsonArraySchema(:final items), JsonSchemaItemsStep()) => items,
  (
    JsonCompositeSchema(:final keyword, :final schemas),
    JsonSchemaBranchStep(keyword: final expectedKeyword, :final index),
  ) =>
    keyword == expectedKeyword && index >= 0 && index < schemas.length ? schemas[index] : null,
  _ => null,
};

JsonSchema? _replaceAt(
  JsonSchema current,
  List<JsonSchemaPathStep> steps,
  int offset,
  JsonSchema replacement,
) {
  if (offset == steps.length) return replacement;
  final step = steps[offset];
  final child = _childAt(current, step);
  if (child == null) return null;
  final updatedChild = _replaceAt(child, steps, offset + 1, replacement);
  if (updatedChild == null) return null;

  return switch ((current, step)) {
    (final JsonObjectSchema object, JsonSchemaPropertyStep(:final name)) => object.copyWith(
      properties: <String, JsonSchema>{...object.properties, name: updatedChild},
    ),
    (final JsonArraySchema array, JsonSchemaItemsStep()) => array.copyWith(items: updatedChild),
    (final JsonCompositeSchema composite, JsonSchemaBranchStep(:final index)) => composite.copyWith(
      schemas: <JsonSchema>[
        for (var branchIndex = 0; branchIndex < composite.schemas.length; branchIndex++)
          branchIndex == index ? updatedChild : composite.schemas[branchIndex],
      ],
    ),
    _ => null,
  };
}
