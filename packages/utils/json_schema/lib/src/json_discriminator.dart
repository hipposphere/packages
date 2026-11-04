import 'json_encodable.dart';
import 'json_schema.dart';

const _componentSchemaPrefix = '#/components/schemas/';

/// OpenAPI `discriminator` for `oneOf` and `anyOf` schemas.
///
/// [propertyName] names the JSON object property whose value selects the
/// matching branch. [mapping] maps those values to component schema ids, for
/// example `{'phase': 'PhaseLine'}`. Values that already look like references,
/// such as `#/components/schemas/PhaseLine`, are kept verbatim.
///
/// When [mapping] is empty, tags can be inferred from component-reference
/// branches whose object schema declares [propertyName] with a single string
/// enum value. See [resolveMapping].
final class JsonDiscriminator implements JsonEncodable {
  /// Creates a discriminator reading [propertyName].
  const JsonDiscriminator({required this.propertyName, this.mapping = const <String, String>{}});

  /// JSON object property whose value selects the matching branch.
  final String propertyName;

  /// Explicit discriminator values mapped to schema ids or references.
  final Map<String, String> mapping;

  /// Returns the JSON reference written for a [mapping] target.
  ///
  /// Plain schema ids expand to `#/components/schemas/<id>`. Targets containing
  /// `#`, `/`, or `:` are treated as references and returned unchanged.
  static String referenceFor(String target) =>
      _isReference(target) ? target : '$_componentSchemaPrefix$target';

  /// Returns the component schema id addressed by a [mapping] target or
  /// `$ref`, or `null` when it does not address a component schema.
  static String? schemaIdFor(String target) {
    if (target.startsWith(_componentSchemaPrefix)) {
      return target.substring(_componentSchemaPrefix.length);
    }
    return _isReference(target) ? null : target;
  }

  /// Returns the single value [schema] declares for [propertyName].
  ///
  /// A branch declares its discriminator value with a one-element enum (the
  /// typed equivalent of JSON Schema `const`) on an object property, for
  /// example `'type': JsonSchema.string(enumValues: ['phase'])`. Returns `null`
  /// when [schema] is not an object or does not pin the property to one value.
  Object? valueOf(JsonSchema schema) {
    if (schema case JsonObjectSchema(:final properties)) {
      final property = properties[propertyName];
      if (property != null && property.enumValues.length == 1) {
        return property.enumValues.single;
      }
    }
    return null;
  }

  /// Returns [mapping] merged with tags inferred from [schemas].
  ///
  /// Explicit entries win. Every component-reference branch that is not an
  /// explicit mapping target and whose schema, found through [lookup], pins
  /// [propertyName] to a single string value contributes `value: schemaId`.
  Map<String, String> resolveMapping(
    Iterable<JsonSchema> schemas, {
    required JsonSchema? Function(String schemaId) lookup,
  }) {
    final explicitTargets = <String?>{for (final target in mapping.values) schemaIdFor(target)};
    final resolved = <String, String>{...mapping};
    for (final schema in schemas) {
      if (schema is! JsonReferenceSchema) continue;
      final schemaId = schemaIdFor(schema.ref);
      if (schemaId == null || explicitTargets.contains(schemaId)) continue;
      final target = lookup(schemaId);
      if (target == null) continue;
      if (valueOf(target) case final String value when !resolved.containsKey(value)) {
        resolved[value] = schemaId;
      }
    }
    return resolved;
  }

  /// Returns a copy whose [mapping] is completed with [resolveMapping].
  JsonDiscriminator withResolvedMapping(
    Iterable<JsonSchema> schemas, {
    required JsonSchema? Function(String schemaId) lookup,
  }) => JsonDiscriminator(
    propertyName: propertyName,
    mapping: resolveMapping(schemas, lookup: lookup),
  );

  /// Serializes the OpenAPI `discriminator` object.
  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'propertyName': propertyName,
    if (mapping.isNotEmpty)
      'mapping': <String, String>{
        for (final entry in mapping.entries) entry.key: referenceFor(entry.value),
      },
  };

  static bool _isReference(String target) =>
      target.contains('#') || target.contains('/') || target.contains(':');
}
