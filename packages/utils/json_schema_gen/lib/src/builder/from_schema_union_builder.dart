part of 'from_schema_model_builder.dart';

// Discriminated unions are generated as a sealed base class plus one
// `final class Union$Variant extends Union` wrapper per branch. Wrapping keeps
// the variant models untouched: they are ordinary `@FromSchema` typedefs that
// may live in other files or libraries, while Dart only allows direct subtypes
// of a sealed class inside the declaring library.

const _fromSchemaAnnotation = TypeChecker.typeNamedLiterally('FromSchema');

/// Build-time description of a generated sealed union.
final class UnionModelSpec {
  const UnionModelSpec({
    required this.publicName,
    required this.className,
    required this.isRoot,
    required this.schema,
    required this.propertyName,
    required this.variants,
    required this.unknownClassName,
  });

  /// Type name used by callers and in `switch` patterns.
  final String publicName;

  /// Declared sealed class name, `_$Name` for root unions.
  final String className;

  /// Whether the union is the `@FromSchema` model itself rather than an inline
  /// property union.
  final bool isRoot;

  /// Union schema re-emitted on inline union classes.
  final JsonCompositeSchema schema;

  /// Discriminator JSON property.
  final String propertyName;

  final List<UnionVariantSpec> variants;

  /// Fallback variant class for unknown tags, or `null` when unknown tags throw.
  final String? unknownClassName;
}

/// One branch of a generated sealed union.
final class UnionVariantSpec {
  const UnionVariantSpec({
    required this.className,
    required this.typeName,
    required this.schemaId,
    required this.tags,
  });

  /// Generated wrapper class name.
  final String className;

  /// Wrapped model type.
  final String typeName;

  /// Referenced component schema id.
  final String schemaId;

  /// JSON discriminator values decoded into this variant.
  final List<Object> tags;
}

/// Resolves component schema ids to schemas for discriminator inference.
///
/// Uses the annotation's registry first, then a `@FromSchema` typedef named
/// like the referenced model and visible from the annotated library.
final class _SchemaLookup {
  _SchemaLookup({required this.element, required this.schemasById, required this.refModels});

  final Element element;
  final Map<String, JsonSchema> schemasById;
  final Map<String, SchemaRefModelSpec> refModels;
  final Map<String, JsonSchema?> _cache = <String, JsonSchema?>{};

  String typeNameFor(String schemaId) => refModels[schemaId]?.typeName ?? _upperCamel(schemaId);

  JsonSchema? call(String schemaId) => _cache.putIfAbsent(
    schemaId,
    () => schemasById[schemaId] ?? _annotatedSchema(typeNameFor(schemaId)),
  );

  JsonSchema? _annotatedSchema(String typeName) {
    final library = element.library;
    if (library == null) {
      return null;
    }
    final declaration = library.firstFragment.scope.lookup(typeName).getter;
    if (declaration is! TypeAliasElement) {
      return null;
    }
    final annotation = _fromSchemaAnnotation.firstAnnotationOf(
      declaration,
      throwOnUnresolved: false,
    );
    if (annotation == null) {
      return null;
    }
    try {
      final reader = ConstantReader(annotation);
      final schema = jsonSchemaFromDartObject(
        reader.read('schema').objectValue,
        element: declaration,
      );
      final registryReader = reader.read('registry');
      final registry = registryReader.isNull
          ? null
          : _jsonSchemaRegistryFromDartObject(registryReader.objectValue, element: declaration);
      return _resolveRootSchema(schema, registry: registry, element: declaration);
    } on InvalidGenerationSourceError {
      return null;
    }
  }
}

/// Collects the root union and inline property unions of one model.
final class _UnionCollector {
  _UnionCollector({required this.lookup, required this.element, required this.unknownVariant});

  final _SchemaLookup lookup;
  final Element element;
  final bool unknownVariant;
  final List<UnionModelSpec> inlineUnions = <UnionModelSpec>[];

  UnionModelSpec root(JsonCompositeSchema schema, {required String publicName}) {
    return _build(schema, publicName: publicName, className: '_\$$publicName', isRoot: true);
  }

  /// Returns [schema] with inline discriminated unions in its properties and
  /// items typed as generated union classes.
  JsonSchema inline(JsonSchema schema, {required String ownerName}) {
    return switch (schema) {
      JsonObjectSchema(:final properties) when properties.isNotEmpty => schema.copyWith(
        properties: <String, JsonSchema>{
          for (final entry in properties.entries)
            entry.key: _typed(entry.value, '$ownerName${_capitalize(_fieldName(entry.key))}'),
        },
      ),
      JsonArraySchema(:final items?) => schema.copyWith(items: _typed(items, '${ownerName}Item')),
      _ => schema,
    };
  }

  JsonSchema _typed(JsonSchema schema, String name) {
    final (schema: inner, :nullable) = _unwrapNullable(schema);
    if (inner is JsonCompositeSchema && _isDiscriminatedUnion(inner)) {
      inlineUnions.add(
        _build(
          _resolveDiscriminators(inner, lookup) as JsonCompositeSchema,
          publicName: name,
          className: name,
          isRoot: false,
        ),
      );
      return inner.copyWith(nullable: nullable, dartType: DartSchemaType.model(name));
    }
    if (inner case JsonArraySchema(:final items?)) {
      final typedItems = _typed(items, '${name}Item');
      if (!identical(typedItems, items)) {
        return inner.copyWith(items: typedItems, nullable: nullable);
      }
    }
    return schema;
  }

  UnionModelSpec _build(
    JsonCompositeSchema schema, {
    required String publicName,
    required String className,
    required bool isRoot,
  }) {
    final discriminator = schema.discriminator!;
    final property = discriminator.propertyName;
    final drafts = <({String schemaId, String typeName, Object? value})>[];
    for (final branch in schema.schemas) {
      if (_isNullSchema(branch)) {
        continue;
      }
      final schemaId = branch is JsonReferenceSchema
          ? JsonDiscriminator.schemaIdFor(branch.ref)
          : null;
      if (schemaId == null) {
        throw _error(
          'Discriminated union $publicName only supports component reference '
          'branches (JsonSchema.componentRef) to @FromSchema object models.',
        );
      }
      if (drafts.any((draft) => draft.schemaId == schemaId)) {
        throw _error('Discriminated union $publicName references $schemaId more than once.');
      }
      final target = lookup(schemaId);
      if (target != null && target is! JsonObjectSchema) {
        throw _error(
          'Discriminated union $publicName branch $schemaId must reference an '
          'object schema.',
        );
      }
      drafts.add((
        schemaId: schemaId,
        typeName: lookup.typeNameFor(schemaId),
        value: target == null ? null : discriminator.valueOf(target),
      ));
    }
    if (drafts.isEmpty) {
      throw _error('Discriminated union $publicName needs at least one branch.');
    }

    final mappedTags = <String, List<String>>{};
    for (final entry in discriminator.mapping.entries) {
      final schemaId = JsonDiscriminator.schemaIdFor(entry.value);
      if (schemaId == null || !drafts.any((draft) => draft.schemaId == schemaId)) {
        throw _error(
          'Discriminator mapping "${entry.key}" of $publicName targets '
          '${entry.value}, which is not one of its branches.',
        );
      }
      (mappedTags[schemaId] ??= <String>[]).add(entry.key);
    }

    final seenTags = <Object, String>{};
    final tagsBySchemaId = <String, List<Object>>{};
    for (final draft in drafts) {
      final mapped = mappedTags[draft.schemaId] ?? const <String>[];
      final value = draft.value;
      final List<Object> tags;
      if (value is String) {
        if (mapped.isNotEmpty && !mapped.contains(value)) {
          throw _error(
            'Discriminator mapping of $publicName maps ${mapped.join(', ')} to '
            '${draft.schemaId}, but that schema pins "$property" to "$value".',
          );
        }
        tags = <Object>[value];
      } else if (value is bool || value is num) {
        // Non-string tags, such as Pydantic `configured: true` branches mapped
        // as "True", are matched by their JSON value.
        tags = <Object>[value!];
      } else if (value != null) {
        throw _error(
          'Discriminator value $value of ${draft.schemaId} in $publicName must '
          'be a string, boolean, or number.',
        );
      } else if (mapped.isNotEmpty) {
        tags = mapped;
      } else {
        throw _error(
          'Cannot determine the "$property" discriminator value of '
          '${draft.schemaId} in $publicName. Pin the property to a single '
          'enum value in the referenced @FromSchema model or add a '
          'JsonDiscriminator.mapping entry.',
        );
      }
      for (final tag in tags) {
        if (seenTags[tag] case final other?) {
          throw _error(
            'Discriminator value $tag of $publicName selects both $other and '
            '${draft.schemaId}.',
          );
        }
        seenTags[tag] = draft.schemaId;
      }
      tagsBySchemaId[draft.schemaId] = tags;
    }

    final suffixes = _variantSuffixes(drafts, tagsBySchemaId);
    return UnionModelSpec(
      publicName: publicName,
      className: className,
      isRoot: isRoot,
      schema: schema,
      propertyName: property,
      variants: <UnionVariantSpec>[
        for (var index = 0; index < drafts.length; index++)
          UnionVariantSpec(
            className: '$publicName\$${suffixes[index]}',
            typeName: drafts[index].typeName,
            schemaId: drafts[index].schemaId,
            tags: tagsBySchemaId[drafts[index].schemaId]!,
          ),
      ],
      unknownClassName: unknownVariant ? '$publicName\$Unknown' : null,
    );
  }

  /// Names wrappers after their string tag (`Union$Phase`), or after the
  /// wrapped type when tags are not strings or would collide.
  List<String> _variantSuffixes(
    List<({String schemaId, String typeName, Object? value})> drafts,
    Map<String, List<Object>> tagsBySchemaId,
  ) {
    bool usable(List<String> suffixes) =>
        suffixes.toSet().length == suffixes.length &&
        !(unknownVariant && suffixes.contains('Unknown'));

    final tags = [for (final draft in drafts) tagsBySchemaId[draft.schemaId]!.first];
    if (tags.every((tag) => tag is String)) {
      final suffixes = [for (final tag in tags) _upperCamel(tag as String)];
      if (usable(suffixes)) {
        return suffixes;
      }
    }
    final suffixes = [for (final draft in drafts) draft.typeName];
    if (!usable(suffixes)) {
      throw _error('Cannot derive unique variant class names for ${drafts.first.typeName}.');
    }
    return suffixes;
  }

  InvalidGenerationSourceError _error(String message) =>
      InvalidGenerationSourceError(message, element: element);
}

bool _isNullSchema(JsonSchema schema) => switch (schema) {
  JsonNullSchema() => true,
  JsonRawSchema(:final schema) => schema['type'] == 'null',
  _ => false,
};

/// Whether [schema] is an `anyOf`/`oneOf` that generates a sealed union.
bool _isDiscriminatedUnion(JsonSchema schema) =>
    schema is JsonCompositeSchema &&
    schema is! JsonAllOfSchema &&
    schema.discriminator != null &&
    schema.dartType == null;

/// Collapses `anyOf`/`oneOf` of exactly one non-null schema plus `null` into
/// that schema, reporting nullability separately because references cannot
/// carry `nullable`.
({JsonSchema schema, bool nullable}) _unwrapNullable(JsonSchema schema) {
  if (schema is JsonCompositeSchema && schema is! JsonAllOfSchema) {
    final nonNull = [
      for (final branch in schema.schemas)
        if (!_isNullSchema(branch)) branch,
    ];
    final hasNull = nonNull.length < schema.schemas.length;
    if (hasNull && nonNull.length == 1 && schema.discriminator == null && schema.dartType == null) {
      return (schema: _unwrapNullable(nonNull.single).schema, nullable: true);
    }
    return (schema: schema, nullable: schema.nullable || hasNull);
  }
  return (schema: schema, nullable: schema.nullable);
}

bool _isNullable(JsonSchema schema) => _unwrapNullable(schema).nullable;

/// Completes discriminator mappings from schemas visible to [lookup], so the
/// re-emitted schema constant documents every tag.
JsonSchema _resolveDiscriminators(JsonSchema schema, _SchemaLookup lookup) => switch (schema) {
  JsonObjectSchema(:final properties) when properties.isNotEmpty => schema.copyWith(
    properties: <String, JsonSchema>{
      for (final entry in properties.entries)
        entry.key: _resolveDiscriminators(entry.value, lookup),
    },
  ),
  JsonArraySchema(:final items?) => schema.copyWith(items: _resolveDiscriminators(items, lookup)),
  JsonCompositeSchema(:final schemas, :final discriminator) => schema.copyWith(
    schemas: <JsonSchema>[for (final branch in schemas) _resolveDiscriminators(branch, lookup)],
    discriminator: discriminator?.withResolvedMapping(schemas, lookup: lookup.call),
  ),
  _ => schema,
};

Iterable<Spec> _unionSpecs(UnionModelSpec union, FromSchemaModelSpec model) sync* {
  final publicType = union.publicName;
  final property = _dartString(union.propertyName);
  final unknownClassName = union.unknownClassName;
  final cases = [
    for (final variant in union.variants)
      for (final tag in variant.tags)
        '${_tagPattern(tag)} => ${variant.className}(${variant.typeName}.fromJson(json)),',
  ];
  final unknownMessage = _dartString(
    'Unknown ${union.publicName} "${union.propertyName}" discriminator value: ',
  );
  final fallback = unknownClassName != null
      ? '_ => $unknownClassName(json),'
      : 'final value => throw FormatException('
            '${unknownMessage.substring(0, unknownMessage.length - 1)}\$value", json),';

  yield Class((builder) {
    builder
      ..docs.addAll([
        if (union.isRoot)
          '/// Sealed union selected by the `${union.propertyName}` property.'
        else
          '/// Sealed union generated for an inline `${union.schema.keyword}` selected by '
              'the `${union.propertyName}` property.',
        '///',
        '/// Variants:',
        for (final variant in union.variants) '/// - [${variant.className}]',
        if (unknownClassName != null) '/// - [$unknownClassName]',
      ])
      ..sealed = true
      ..name = union.className
      ..implements.add(refer('JsonEncodable'))
      ..constructors.add(Constructor((constructor) => constructor..constant = true))
      ..fields.addAll([
        if (union.isRoot) ...[
          _schemaIdField(model.schemaId),
          _schemaField(model.emittedSchema, schemaId: model.schemaId),
          _schemaRefField(),
        ] else
          _schemaField(union.schema, schemaId: null),
        Field((builder) {
          builder
            ..docs.add('/// JSON property whose value selects the variant.')
            ..static = true
            ..modifier = FieldModifier.constant
            ..name = 'discriminatorProperty'
            ..assignment = _literalString(union.propertyName).code;
        }),
      ])
      ..methods.addAll([
        Method((builder) {
          builder
            ..annotations.add(refer('override'))
            ..returns = refer('Map<String, Object?>')
            ..name = 'toJson';
        }),
        _decodeMethod(publicType, 'fromJson(value as Map<String, Object?>)'),
        Method((builder) {
          builder
            ..static = true
            ..returns = refer(publicType)
            ..name = 'fromJson'
            ..requiredParameters.add(_typedParameter('json', refer('Map<String, Object?>')))
            ..body = Code('''
return switch (json[$property]) {
${cases.join('\n')}
$fallback
};
''');
        }),
      ]);
  });

  for (final variant in union.variants) {
    yield _unionWrapper(
      className: variant.className,
      superclass: publicType,
      docs: [
        '/// [$publicType] variant for `${union.propertyName}` '
            '${variant.tags.map((tag) => '`${jsonEncode(tag)}`').join(', ')}.',
      ],
      field: Field((builder) {
        builder
          ..modifier = FieldModifier.final$
          ..type = refer(variant.typeName)
          ..name = 'value';
      }),
      toJson: 'value.toJson()',
    );
  }

  if (unknownClassName != null) {
    yield _unionWrapper(
      className: unknownClassName,
      superclass: publicType,
      docs: [
        '/// [$publicType] variant for a `${union.propertyName}` value unknown at generation',
        '/// time. Keeps the raw JSON object so it round-trips unchanged.',
      ],
      field: Field((builder) {
        builder
          ..modifier = FieldModifier.final$
          ..type = refer('Map<String, Object?>')
          ..name = 'json';
      }),
      toJson: 'json',
      extraMethods: [
        Method((builder) {
          builder
            ..docs.add('/// The unrecognized `${union.propertyName}` value.')
            ..type = MethodType.getter
            ..returns = refer('Object?')
            ..name = 'discriminatorValue'
            ..lambda = true
            ..body = Code('json[$property]');
        }),
      ],
    );
  }
}

Class _unionWrapper({
  required String className,
  required String superclass,
  required List<String> docs,
  required Field field,
  required String toJson,
  List<Method> extraMethods = const <Method>[],
}) {
  return Class((builder) {
    builder
      ..docs.addAll(docs)
      ..modifier = ClassModifier.final$
      ..name = className
      ..extend = refer(superclass)
      ..constructors.add(
        Constructor((constructor) {
          constructor
            ..constant = true
            ..requiredParameters.add(
              Parameter((parameter) {
                parameter
                  ..name = field.name
                  ..toThis = true;
              }),
            );
        }),
      )
      ..fields.add(field)
      ..methods.addAll([
        ...extraMethods,
        Method((builder) {
          builder
            ..annotations.add(refer('override'))
            ..returns = refer('Map<String, Object?>')
            ..name = 'toJson'
            ..lambda = true
            ..body = Code(toJson);
        }),
      ]);
  });
}

String _tagPattern(Object tag) => switch (tag) {
  final String value => _dartString(value),
  _ => '$tag',
};
