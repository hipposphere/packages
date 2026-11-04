import 'json_discriminator.dart';
import 'json_schema.dart';

/// Collection of top-level JSON Schemas installed on an app.
///
/// Generated route and SQL registries use this to expose the schema graph that
/// OpenAPI generation, typed clients, and route metadata can share.
final class JsonSchemaRegistry {
  /// Creates a registry containing [schemas].
  const JsonSchemaRegistry({required this.schemas});

  /// All top-level schemas known to the registry.
  final List<JsonSchema> schemas;

  /// Looks up a schema by its JSON Schema `$id`.
  JsonSchema? schemaFor(String id) {
    for (final schema in schemas) {
      if (schema.id == id) {
        return schema;
      }
    }
    return null;
  }

  /// Returns serialized schemas keyed by schema id.
  ///
  /// Schemas without an [JsonSchema.id] are skipped because they cannot be
  /// addressed from the map. Discriminator mappings are completed with
  /// [resolveDiscriminators].
  Map<String, Map<String, Object?>> asMap() =>
      Map<String, Map<String, Object?>>.fromEntries(<MapEntry<String, Map<String, Object?>>>[
        for (final schema in schemas)
          if (schema.id case final id?) MapEntry(id, resolveDiscriminators(schema).toJson()),
      ]);

  /// Returns [schema] with every nested [JsonDiscriminator.mapping] completed
  /// from the schemas in this registry.
  ///
  /// See [JsonDiscriminator.resolveMapping] for the inference rules.
  JsonSchema resolveDiscriminators(JsonSchema schema) => switch (schema) {
    JsonObjectSchema(:final properties) when properties.isNotEmpty => schema.copyWith(
      properties: <String, JsonSchema>{
        for (final entry in properties.entries) entry.key: resolveDiscriminators(entry.value),
      },
    ),
    JsonArraySchema(:final items?) => schema.copyWith(items: resolveDiscriminators(items)),
    JsonCompositeSchema(:final schemas, :final discriminator) => schema.copyWith(
      schemas: <JsonSchema>[for (final branch in schemas) resolveDiscriminators(branch)],
      discriminator: discriminator?.withResolvedMapping(schemas, lookup: schemaFor),
    ),
    _ => schema,
  };
}
