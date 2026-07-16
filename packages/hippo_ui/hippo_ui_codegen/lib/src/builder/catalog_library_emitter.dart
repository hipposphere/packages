/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:convert';

import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:hippo_analysis/hippo_analysis.dart';

import 'catalog_metadata.dart';

class CatalogLibraryEmitter {
  CatalogLibraryEmitter({DartFormatter? formatter})
    : _formatter = formatter ?? createHippoDartFormatter();

  final DartFormatter _formatter;

  String emit(CatalogMetadata catalog) {
    final targetImportUris = _targetImportUris(catalog).toList();
    final converterImportUris = _converterImportUris(catalog).toList();
    final enumImportUris = _enumImportUris(catalog).toList();
    final flutterPreviewBridges = catalog.previews
        .where((preview) => preview.createsFlutterPreviewBridge)
        .toList();
    final hasIconDataOptions = catalog.previews.any(
      (preview) => preview.options.any((option) => option is GeneratedIconDataOptionMetadata),
    );
    final imports = <String>{
      if (flutterPreviewBridges.isNotEmpty) 'package:flutter/widget_previews.dart',
      if (flutterPreviewBridges.isNotEmpty || hasIconDataOptions) 'package:flutter/widgets.dart',
      ...targetImportUris,
      ...converterImportUris,
      ...enumImportUris,
    };
    final hippoUiExportedByFlutter = imports.contains(
      'package:hippo_ui_flutter/hippo_ui_flutter.dart',
    );

    final library = Library(
      (builder) => builder
        ..comments.add('GENERATED CODE - DO NOT MODIFY BY HAND.')
        ..directives.addAll(<Directive>[
          if (!hippoUiExportedByFlutter) Directive.import('package:hippo_ui/hippo_ui.dart'),
          ...imports.map(Directive.import),
        ])
        ..body.addAll(<Spec>[
          _generatedListField(
            name: 'hippoUiGeneratedPreviews',
            itemType: 'HippoUiGeneratedPreview',
            values: catalog.previews.map(_previewExpression),
          ),
          ..._flutterPreviewBridgeMethods(flutterPreviewBridges),
        ]),
    );

    final emitter = DartEmitter(useNullSafetySyntax: true);
    return _formatter.format('${library.accept(emitter)}');
  }

  Field _generatedListField({
    required String name,
    required String itemType,
    required Iterable<Expression> values,
  }) {
    return Field(
      (builder) => builder
        ..name = name
        ..modifier = FieldModifier.final$
        ..type = _listType(itemType)
        ..assignment = literalList(values, refer(itemType)).code,
    );
  }

  Expression _previewExpression(GeneratedPreviewMetadata preview) {
    return refer('HippoUiGeneratedPreview').newInstance(const <Expression>[], {
      'id': literalString(preview.id),
      'targetName': literalString(preview.targetName),
      'name': literalString(preview.name),
      'path': literalString(preview.path),
      if (preview.description case final description?) 'description': literalString(description),
      if (preview.options.isNotEmpty)
        'options': literalList(
          preview.options.map(_optionExpression),
          refer('HippoUiGeneratedOption'),
        ),
      if (preview.optionConverters.isNotEmpty)
        'optionConverters': literalList(
          preview.optionConverters.map(_optionConverterExpression),
          refer('HippoUiGeneratedOptionConverter'),
        ),
      ...?_previewBuilderMap(preview),
      if (preview.tags.isNotEmpty) 'tags': _stringList(preview.tags),
    });
  }

  Iterable<String> _targetImportUris(CatalogMetadata catalog) {
    return <String>{
      for (final preview in catalog.previews)
        if (preview.targetKind != GeneratedPreviewTargetKind.other) preview.targetImportUri,
    };
  }

  Iterable<String> _converterImportUris(CatalogMetadata catalog) {
    return <String>{
      for (final preview in catalog.previews)
        for (final converter in preview.optionConverters) converter.converterImportUri,
      for (final preview in catalog.previews)
        for (final option in preview.options)
          if (option.converter case final converter?) converter.converterImportUri,
    }.where((uri) => uri != 'package:hippo_ui/hippo_ui.dart');
  }

  Iterable<String> _enumImportUris(CatalogMetadata catalog) {
    return <String>{
      for (final preview in catalog.previews)
        for (final option in preview.options)
          if (option is GeneratedEnumOptionMetadata) ?option.enumImportUri,
    }.where((uri) => uri != 'dart:core');
  }

  Expression _optionConverterExpression(GeneratedOptionConverterMetadata converter) {
    return refer('HippoUiGeneratedOptionConverter').newInstance(const <Expression>[], {
      'optionKey': literalString(converter.optionKey),
      'converter': refer(
        converter.converterName,
        converter.converterImportUri,
      ).constInstance(const <Expression>[]),
    });
  }

  Expression _optionExpression(GeneratedOptionMetadata option) {
    return switch (option) {
      GeneratedBooleanOptionMetadata() => _baseOptionExpression(
        constructor: 'HippoUiGeneratedBooleanOption',
        option: option,
      ),
      GeneratedIntegerOptionMetadata() => _baseOptionExpression(
        constructor: 'HippoUiGeneratedIntegerOption',
        option: option,
        named: <String, Expression>{
          if (option.min case final min?) 'min': literalNum(min),
          if (option.max case final max?) 'max': literalNum(max),
          if (option.step case final step?) 'step': literalNum(step),
          if (option.values.isNotEmpty)
            'values': literalList(
              option.values.map(_optionValueExpression),
              refer('HippoUiGeneratedOptionValue<int>'),
            ),
        },
      ),
      GeneratedDoubleOptionMetadata() => _baseOptionExpression(
        constructor: 'HippoUiGeneratedDoubleOption',
        option: option,
        named: <String, Expression>{
          if (option.min case final min?) 'min': literalNum(min),
          if (option.max case final max?) 'max': literalNum(max),
          if (option.step case final step?) 'step': literalNum(step),
          if (option.values.isNotEmpty)
            'values': literalList(
              option.values.map(_optionValueExpression),
              refer('HippoUiGeneratedOptionValue<double>'),
            ),
        },
      ),
      GeneratedTextOptionMetadata() => _baseOptionExpression(
        constructor: 'HippoUiGeneratedTextOption',
        option: option,
        named: <String, Expression>{
          if (option.values.isNotEmpty)
            'values': literalList(
              option.values.map(_optionValueExpression),
              refer('HippoUiGeneratedOptionValue<String>'),
            ),
        },
      ),
      GeneratedIconDataOptionMetadata() => _baseOptionExpression(
        constructor: 'HippoUiGeneratedTextOption',
        option: option,
        named: <String, Expression>{
          if (option.values.isNotEmpty)
            'values': literalList(
              option.values.map(_iconDataOptionValueExpression),
              refer('HippoUiGeneratedOptionValue<String>'),
            ),
        },
      ),
      GeneratedEnumOptionMetadata() => _baseOptionExpression(
        constructor: 'HippoUiGeneratedEnumOption',
        option: option,
        named: <String, Expression>{
          if (option.enumType case final enumType?) 'enumType': literalString(enumType),
          if (option.values.isNotEmpty)
            'values': literalList(
              option.values.map(_optionValueExpression),
              refer('HippoUiGeneratedOptionValue<String>'),
            ),
        },
      ),
      GeneratedObjectOptionMetadata() => _baseOptionExpression(
        constructor: 'HippoUiGeneratedObjectOption',
        option: option,
        defaultValue: _literalJson(option.defaultValue),
        named: <String, Expression>{
          if (option.values.isNotEmpty)
            'values': literalList(
              option.values.map(_optionValueExpression),
              refer('HippoUiGeneratedOptionValue<Map<String, Object?>>'),
            ),
        },
      ),
      GeneratedUnknownOptionMetadata() => _baseOptionExpression(
        constructor: 'HippoUiGeneratedUnknownOption',
        option: option,
      ),
    };
  }

  Expression _baseOptionExpression({
    required String constructor,
    required GeneratedOptionMetadata option,
    Expression? defaultValue,
    Map<String, Expression> named = const <String, Expression>{},
  }) {
    return refer(constructor).newInstance(const <Expression>[], {
      'key': literalString(option.key),
      if (option.label case final label?) 'label': literalString(label),
      if (option.description case final description?) 'description': literalString(description),
      if (defaultValue != null)
        'defaultValue': defaultValue
      else if (option.defaultValue case final defaultValue?)
        'defaultValue': literal(defaultValue),
      ...named,
    });
  }

  Expression _optionValueExpression(GeneratedOptionValueMetadata<Object> optionValue) {
    return refer('HippoUiGeneratedOptionValue').newInstance(const <Expression>[], {
      'value': _literalJson(optionValue.value),
      if (optionValue.label case final label?) 'label': literalString(label),
      if (optionValue.description case final description?)
        'description': literalString(description),
    });
  }

  Expression _iconDataOptionValueExpression(
    GeneratedOptionValueMetadata<GeneratedIconDataMetadata> optionValue,
  ) {
    return refer('HippoUiGeneratedOptionValue').newInstance(const <Expression>[], {
      'value': literalString(optionValue.value.token),
      if (optionValue.label case final label?) 'label': literalString(label),
      if (optionValue.description case final description?)
        'description': literalString(description),
    });
  }

  Expression? _previewBuilderExpression(GeneratedPreviewMetadata preview) {
    return switch (preview.targetKind) {
      GeneratedPreviewTargetKind.classDeclaration => CodeExpression(
        Code.scope((allocate) {
          return '(configuration) => ${_classPreviewConstructionSource(preview, allocate)}';
        }),
      ),
      GeneratedPreviewTargetKind.functionDeclaration => CodeExpression(
        Code.scope((allocate) {
          final target = allocate(refer(preview.targetName, preview.targetImportUri));
          if (preview.targetUsesConfiguration) {
            return '(configuration) => $target(configuration)';
          }
          return '(_) => $target()';
        }),
      ),
      GeneratedPreviewTargetKind.other => null,
    };
  }

  Iterable<Method> _flutterPreviewBridgeMethods(List<GeneratedPreviewMetadata> previews) sync* {
    for (final preview in previews) {
      yield _flutterPreviewBridgeMethod(preview);
    }
  }

  Method _flutterPreviewBridgeMethod(GeneratedPreviewMetadata preview) {
    return Method(
      (builder) => builder
        ..annotations.add(
          refer('Preview').call(const <Expression>[], {
            'group': literalString(preview.path),
            'name': literalString(preview.name),
          }),
        )
        ..returns = refer('Widget')
        ..name = _flutterPreviewBridgeName(preview)
        ..body = Code.scope((allocate) {
          final target = _classPreviewConstructionSource(preview, allocate);
          if (preview.options.isEmpty) {
            return 'return $target;';
          }
          return '''
final configuration = ${_defaultConfigurationMapSource(preview)};
return $target;
''';
        }),
    );
  }

  String _classPreviewConstructionSource(
    GeneratedPreviewMetadata preview,
    String Function(Reference) allocate,
  ) {
    final target = allocate(refer(preview.targetName, preview.targetImportUri));
    final arguments = preview.options
        .map((option) {
          return '${option.key}: ${_configurationValueSource(option, preview, allocate)}';
        })
        .join(', ');
    return '$target($arguments)';
  }

  Map<String, Expression>? _previewBuilderMap(GeneratedPreviewMetadata preview) {
    final builder = _previewBuilderExpression(preview);
    if (builder == null) {
      return null;
    }
    return <String, Expression>{'builder': builder};
  }

  String _configurationValueSource(
    GeneratedOptionMetadata option,
    GeneratedPreviewMetadata preview,
    String Function(Reference) allocate,
  ) {
    GeneratedOptionConverterMetadata? converter;
    converter = option.converter;
    for (final candidate in preview.optionConverters) {
      if (converter != null) {
        break;
      }
      if (candidate.optionKey == option.key) {
        converter = candidate;
        break;
      }
    }
    if (converter != null && option is! GeneratedIconDataOptionMetadata) {
      final converterName = allocate(refer(converter.converterName, converter.converterImportUri));
      return 'const $converterName().convert(configuration[${jsonEncode(option.key)}])';
    }

    final read = 'configuration[${jsonEncode(option.key)}]';
    return switch (option) {
      GeneratedBooleanOptionMetadata() => '($read as bool?) ?? ${option.defaultValue}',
      GeneratedIntegerOptionMetadata() => '($read as int?) ?? ${option.defaultValue}',
      GeneratedDoubleOptionMetadata() => '($read as double?) ?? ${option.defaultValue}',
      GeneratedTextOptionMetadata() => '($read as String?) ?? ${jsonEncode(option.defaultValue)}',
      GeneratedIconDataOptionMetadata() => _iconDataValueSource(option, read),
      GeneratedEnumOptionMetadata() => _enumValueSource(option, read, allocate),
      GeneratedObjectOptionMetadata() =>
        '($read as Map<String, Object?>?) ?? ${_sourceFor(_literalJson(option.defaultValue))}',
      GeneratedUnknownOptionMetadata() => read,
    };
  }

  String _iconDataValueSource(GeneratedIconDataOptionMetadata option, String read) {
    final iconsByToken = <String, GeneratedIconDataMetadata>{
      option.defaultIcon.token: option.defaultIcon,
      for (final value in option.values) value.value.token: value.value,
    };
    final cases = iconsByToken.entries
        .map(
          (entry) => '${jsonEncode(entry.key)} => ${_sourceFor(_iconDataExpression(entry.value))},',
        )
        .join('\n');
    final fallback = _sourceFor(_iconDataExpression(option.defaultIcon));
    return '''switch (($read as String?) ?? ${jsonEncode(option.defaultValue)}) {
$cases
_ => $fallback,
}''';
  }

  Expression _iconDataExpression(GeneratedIconDataMetadata icon) {
    return refer('IconData').constInstance(
      <Expression>[literalNum(icon.codePoint)],
      {
        if (icon.fontFamily case final fontFamily?) 'fontFamily': literalString(fontFamily),
        if (icon.fontPackage case final fontPackage?) 'fontPackage': literalString(fontPackage),
        if (icon.matchTextDirection) 'matchTextDirection': literalBool(true),
        if (icon.fontFamilyFallback.isNotEmpty)
          'fontFamilyFallback': literalList(
            icon.fontFamilyFallback.map(literalString),
            refer('String'),
          ),
      },
    );
  }

  String _enumValueSource(
    GeneratedEnumOptionMetadata option,
    String read,
    String Function(Reference) allocate,
  ) {
    final enumType = option.enumType;
    final enumImportUri = option.enumImportUri;
    if (enumType == null || enumImportUri == null) {
      return '($read as String?) ?? ${jsonEncode(option.defaultValue)}';
    }

    final enumReference = allocate(refer(enumType, enumImportUri));
    return '$enumReference.values.byName(($read as String?) ?? ${jsonEncode(option.defaultValue)})';
  }

  String _sourceFor(Expression expression) {
    return '${expression.accept(DartEmitter(useNullSafetySyntax: true))}';
  }

  Expression _literalJson(Object? value) {
    return switch (value) {
      final Map<String, Object?> map => literalMap(
        map.map((key, value) => MapEntry(literalString(key), _literalJson(value))),
        refer('String'),
        refer('Object?'),
      ),
      final List<Object?> list => literalList(list.map(_literalJson), refer('Object?')),
      _ => literal(value),
    };
  }

  String _defaultConfigurationMapSource(GeneratedPreviewMetadata preview) {
    return _sourceFor(
      literalMap(
        <Expression, Expression>{
          for (final option in preview.options)
            literalString(option.key): _literalJson(option.defaultValue),
        },
        refer('String'),
        refer('Object?'),
      ),
    );
  }

  String _flutterPreviewBridgeName(GeneratedPreviewMetadata preview) {
    return 'hippoUiFlutterPreview${_identifierPart(preview.targetName)}${_stableHash(preview.id)}';
  }

  String _identifierPart(String value) {
    final segments = value
        .split(RegExp(r'[^a-zA-Z0-9]+'))
        .where((segment) => segment.isNotEmpty)
        .toList();
    if (segments.isEmpty) {
      return 'Preview';
    }
    return segments.map(_upperFirst).join();
  }

  String _upperFirst(String value) {
    if (value.length == 1) {
      return value.toUpperCase();
    }
    return value[0].toUpperCase() + value.substring(1);
  }

  String _stableHash(String value) {
    var hash = 0x811c9dc5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193).toUnsigned(32);
    }
    return hash.toRadixString(36);
  }

  Expression _stringList(List<String> values) {
    return literalList(values.map(literalString), refer('String'));
  }

  Reference _listType(String itemType) {
    return TypeReference(
      (builder) => builder
        ..symbol = 'List'
        ..types.add(refer(itemType)),
    );
  }
}
