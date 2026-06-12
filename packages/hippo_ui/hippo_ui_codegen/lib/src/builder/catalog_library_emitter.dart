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

import 'catalog_metadata.dart';

class CatalogLibraryEmitter {
  CatalogLibraryEmitter({DartFormatter? formatter})
    : _formatter = formatter ?? DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);

  final DartFormatter _formatter;

  String emit(CatalogMetadata catalog) {
    final targetImportUris = _targetImportUris(catalog).toList();
    final converterImportUris = _converterImportUris(catalog).toList();
    final enumImportUris = _enumImportUris(catalog).toList();
    final imports = <String>{...targetImportUris, ...converterImportUris, ...enumImportUris};
    final hippoUiExportedByFlutter = imports.contains(
      'package:hippo_ui_flutter/hippo_ui_flutter.dart',
    );

    final library = Library(
      (builder) => builder
        ..comments.add('GENERATED CODE - DO NOT MODIFY BY HAND.')
        ..directives.addAll(<Directive>[
          if (!hippoUiExportedByFlutter) Directive.import('package:hippo_ui/hippo_ui.dart'),
          ...targetImportUris.map(Directive.import),
          ...converterImportUris.map(Directive.import),
          ...enumImportUris.map(Directive.import),
        ])
        ..body.addAll(<Spec>[
          _generatedListField(
            name: 'hippoUiGeneratedPreviews',
            itemType: 'HippoUiGeneratedPreview',
            values: catalog.previews.map(_previewExpression),
          ),
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

  Expression? _previewBuilderExpression(GeneratedPreviewMetadata preview) {
    return switch (preview.targetKind) {
      GeneratedPreviewTargetKind.classDeclaration => CodeExpression(
        Code.scope((allocate) {
          final target = allocate(refer(preview.targetName, preview.targetImportUri));
          final arguments = preview.options
              .map((option) {
                return '${option.key}: ${_configurationValueSource(option, preview, allocate)}';
              })
              .join(', ');
          return '(configuration) => $target($arguments)';
        }),
      ),
      GeneratedPreviewTargetKind.functionDeclaration => CodeExpression(
        Code.scope((allocate) {
          final target = allocate(refer(preview.targetName, preview.targetImportUri));
          return '(configuration) => $target(configuration)';
        }),
      ),
      GeneratedPreviewTargetKind.other => null,
    };
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
    if (converter != null) {
      final converterName = allocate(refer(converter.converterName, converter.converterImportUri));
      return 'const $converterName().convert(configuration[${jsonEncode(option.key)}])';
    }

    final read = 'configuration[${jsonEncode(option.key)}]';
    return switch (option) {
      GeneratedBooleanOptionMetadata() => '($read as bool?) ?? ${option.defaultValue}',
      GeneratedIntegerOptionMetadata() => '($read as int?) ?? ${option.defaultValue}',
      GeneratedDoubleOptionMetadata() => '($read as double?) ?? ${option.defaultValue}',
      GeneratedTextOptionMetadata() => '($read as String?) ?? ${jsonEncode(option.defaultValue)}',
      GeneratedEnumOptionMetadata() => _enumValueSource(option, read, allocate),
      GeneratedObjectOptionMetadata() =>
        '($read as Map<String, Object?>?) ?? ${_sourceFor(_literalJson(option.defaultValue))}',
      GeneratedUnknownOptionMetadata() => read,
    };
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
