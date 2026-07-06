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

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:hippo_ui/hippo_ui.dart';
import 'package:source_gen/source_gen.dart';

import 'catalog_metadata.dart';

class AnnotationCatalogReader {
  const AnnotationCatalogReader();

  static const TypeChecker _previewChecker = TypeChecker.typeNamed(
    HippoWidgetPreviewMetadata,
    inPackage: 'hippo_ui',
  );
  static const TypeChecker _fieldChecker = TypeChecker.typeNamed(
    HippoWidgetPreviewField,
    inPackage: 'hippo_ui',
  );
  static final Uri _flutterPreviewLibraryUri = Uri.parse(
    'package:flutter/src/widget_previews/widget_previews.dart',
  );
  static final Uri _flutterWidgetLibraryUri = Uri.parse(
    'package:flutter/src/widgets/framework.dart',
  );

  Future<CatalogMetadata> readPackageCatalog(BuildStep buildStep, List<AssetId> libraries) async {
    final previews = <GeneratedPreviewMetadata>[];

    for (final asset in libraries) {
      final library = await buildStep.resolver.libraryFor(asset);
      final reader = LibraryReader(library);
      previews.addAll(
        reader.annotatedWith(_previewChecker).map((annotation) {
          return _previewFrom(
            annotation.annotation.objectValue,
            targetName: annotation.element.displayName,
            targetImportUri: _libraryImportUri(buildStep, asset),
            targetKind: _targetKind(annotation.element),
            targetElement: annotation.element,
          );
        }),
      );
    }

    return CatalogMetadata(previews: previews);
  }

  GeneratedPreviewMetadata _previewFrom(
    DartObject object, {
    required String targetName,
    required String targetImportUri,
    required GeneratedPreviewTargetKind targetKind,
    required Element targetElement,
  }) {
    return GeneratedPreviewMetadata(
      id: object.getField('id')?.toStringValue() ?? '$targetImportUri#$targetName',
      targetName: targetName,
      targetImportUri: targetImportUri,
      targetKind: targetKind,
      name: _requiredString(object, 'name'),
      path: _requiredString(object, 'path'),
      targetUsesConfiguration: _targetUsesConfiguration(targetElement),
      createsFlutterPreviewBridge: _createsFlutterPreviewBridge(object, targetElement),
      description: object.getField('description')?.toStringValue(),
      options: _fieldOptionList(targetElement),
      tags: _stringList(object.getField('tags')),
    );
  }

  List<String> _stringList(DartObject? object) {
    return object?.toListValue()?.map((value) => value.toStringValue() ?? '').toList() ??
        const <String>[];
  }

  List<GeneratedOptionMetadata> _fieldOptionList(Element element) {
    if (element is! ClassElement) {
      return const <GeneratedOptionMetadata>[];
    }

    if (element.constructors.isEmpty) {
      return const <GeneratedOptionMetadata>[];
    }
    final constructor = element.constructors.first;

    return constructor.formalParameters
        .map(_fieldOptionFrom)
        .whereType<GeneratedOptionMetadata>()
        .toList();
  }

  GeneratedOptionMetadata? _fieldOptionFrom(FormalParameterElement parameter) {
    final annotations = <ElementAnnotation>[
      ...parameter.metadata.annotations,
      ...parameter.firstFragment.metadata.annotations,
    ];
    for (final annotation in annotations) {
      final value = annotation.computeConstantValue();
      final type = value?.type;
      if (value != null && type != null && _fieldChecker.isAssignableFromType(type)) {
        final option = value.getField('option');
        if (option == null || option.isNull) {
          return null;
        }
        return _optionFrom(option, keyOverride: parameter.name);
      }
    }
    return null;
  }

  GeneratedOptionMetadata _optionFrom(DartObject object, {String? keyOverride}) {
    final type = object.type?.getDisplayString();
    final key = keyOverride ?? object.getField('key')?.toStringValue() ?? '';
    final label = object.getField('label')?.toStringValue();
    final description = object.getField('description')?.toStringValue();
    final defaultValue = _primitiveValueFrom(object.getField('defaultValue'));
    final converter = _optionConverterFromOption(object, key);

    if (type == 'HippoUiBooleanOption') {
      return GeneratedBooleanOptionMetadata(
        key: key,
        label: label,
        description: description,
        defaultValue: defaultValue as bool? ?? false,
        converter: converter,
      );
    }

    if (type == 'HippoUiIntegerOption') {
      return GeneratedIntegerOptionMetadata(
        key: key,
        label: label,
        description: description,
        defaultValue: defaultValue as int? ?? 0,
        min: object.getField('min')?.toIntValue(),
        max: object.getField('max')?.toIntValue(),
        step: object.getField('step')?.toIntValue(),
        values: _optionValueList<int>(object.getField('values')),
        converter: converter,
      );
    }

    if (type == 'HippoUiDoubleOption') {
      return GeneratedDoubleOptionMetadata(
        key: key,
        label: label,
        description: description,
        defaultValue: defaultValue as double? ?? 0,
        min: object.getField('min')?.toDoubleValue(),
        max: object.getField('max')?.toDoubleValue(),
        step: object.getField('step')?.toDoubleValue(),
        values: _optionValueList<double>(object.getField('values')),
        converter: converter,
      );
    }

    if (type == 'HippoUiAlignmentOption') {
      return GeneratedTextOptionMetadata(
        key: key,
        label: label,
        description: description,
        defaultValue: _constantNameFrom(object.getField('defaultValue')) ?? 'center',
        values: _constantOptionValueList(object.getField('values')),
        converter: converter,
      );
    }

    if (type == 'HippoUiColorOption') {
      return GeneratedIntegerOptionMetadata(
        key: key,
        label: label,
        description: description,
        defaultValue: _colorIntFrom(object.getField('defaultValue')) ?? 0xff000000,
        values: _colorOptionValueList(object.getField('values')),
        converter: converter,
      );
    }

    if (type == 'HippoUiEdgeInsetsOption') {
      return GeneratedObjectOptionMetadata(
        key: key,
        label: label,
        description: description,
        defaultValue:
            _edgeInsetsMapFrom(object.getField('defaultValue')) ?? const <String, Object?>{},
        values: _mappedObjectOptionValueList(object.getField('values'), _edgeInsetsMapFrom),
        converter: converter,
      );
    }

    if (type == 'HippoUiBorderRadiusOption') {
      return GeneratedObjectOptionMetadata(
        key: key,
        label: label,
        description: description,
        defaultValue:
            _borderRadiusMapFrom(object.getField('defaultValue')) ?? const <String, Object?>{},
        values: _mappedObjectOptionValueList(object.getField('values'), _borderRadiusMapFrom),
        converter: converter,
      );
    }

    if (type == 'HippoUiSizeOption') {
      return GeneratedObjectOptionMetadata(
        key: key,
        label: label,
        description: description,
        defaultValue: _sizeMapFrom(object.getField('defaultValue')) ?? const <String, Object?>{},
        values: _mappedObjectOptionValueList(object.getField('values'), _sizeMapFrom),
        converter: converter,
      );
    }

    if (type == 'HippoUiDurationOption') {
      return GeneratedIntegerOptionMetadata(
        key: key,
        label: label,
        description: description,
        defaultValue: _durationMillisFrom(object.getField('defaultValue')) ?? 0,
        min: _durationMillisFrom(object.getField('min')),
        max: _durationMillisFrom(object.getField('max')),
        step: _durationMillisFrom(object.getField('step')),
        values: _durationOptionValueList(object.getField('values')),
        converter: converter,
      );
    }

    if (type == 'HippoUiCurveOption') {
      return GeneratedTextOptionMetadata(
        key: key,
        label: label,
        description: description,
        defaultValue: _constantNameFrom(object.getField('defaultValue')) ?? 'linear',
        values: _constantOptionValueList(object.getField('values')),
        converter: converter,
      );
    }

    if (type == 'HippoUiBoxConstraintsOption') {
      return GeneratedObjectOptionMetadata(
        key: key,
        label: label,
        description: description,
        defaultValue:
            _boxConstraintsMapFrom(object.getField('defaultValue')) ?? const <String, Object?>{},
        values: _mappedObjectOptionValueList(object.getField('values'), _boxConstraintsMapFrom),
        converter: converter,
      );
    }

    if (type == 'HippoUiIconDataOption') {
      return GeneratedTextOptionMetadata(
        key: key,
        label: label,
        description: description,
        defaultValue: _iconDataStringFrom(object.getField('defaultValue')) ?? '{"codePoint":0}',
        values: _iconDataOptionValueList(object.getField('values')),
        converter: converter,
      );
    }

    if (type?.startsWith('HippoUiTextStyleOption') ?? false) {
      return GeneratedTextOptionMetadata(
        key: key,
        label: label,
        description: description,
        defaultValue: defaultValue as String? ?? '',
        values: _optionValueList<String>(object.getField('values')),
        converter: converter,
      );
    }

    if (type?.startsWith('HippoUiWidgetOption') ?? false) {
      return GeneratedTextOptionMetadata(
        key: key,
        label: label,
        description: description,
        defaultValue: defaultValue as String? ?? '',
        values: _optionValueList<String>(object.getField('values')),
        converter: converter,
      );
    }

    if (type == 'HippoUiTextOption') {
      return GeneratedTextOptionMetadata(
        key: key,
        label: label,
        description: description,
        defaultValue: defaultValue as String? ?? '',
        values: _optionValueList<String>(object.getField('values')),
        converter: converter,
      );
    }

    if (type?.startsWith('HippoUiEnumOption') ?? false) {
      return GeneratedEnumOptionMetadata(
        key: key,
        label: label,
        description: description,
        defaultValue: _constantNameFrom(object.getField('defaultValue')) ?? '',
        enumType: object.getField('defaultValue')?.type?.getDisplayString(),
        enumImportUri: _publicImportUri(
          object.getField('defaultValue')?.type?.element?.library?.uri.toString(),
        ),
        values: _enumOptionValueList(object.getField('values')),
        converter: converter,
      );
    }

    if (type == 'HippoUiObjectOption') {
      return GeneratedObjectOptionMetadata(
        key: key,
        label: label,
        description: description,
        defaultValue: _jsonMapFrom(object.getField('defaultValue')) ?? const <String, Object?>{},
        values: _objectOptionValueList(object.getField('values')),
        converter: converter,
      );
    }

    return GeneratedUnknownOptionMetadata(
      key: key,
      label: label,
      description: description,
      defaultValue: defaultValue,
      converter: converter,
    );
  }

  GeneratedOptionConverterMetadata? _optionConverterFromOption(DartObject object, String key) {
    return _converterMetadataFromObject(object.getField('converter'), optionKey: key);
  }

  GeneratedOptionConverterMetadata? _converterMetadataFromObject(
    DartObject? object, {
    required String optionKey,
  }) {
    if (object == null || object.isNull) {
      return null;
    }

    final converterElement = object.type?.element;
    final converterName = converterElement?.displayName;
    final converterImportUri = _publicImportUri(converterElement?.library?.uri.toString());
    if (converterName == null || converterName.isEmpty || converterImportUri == null) {
      return null;
    }

    return GeneratedOptionConverterMetadata(
      optionKey: optionKey,
      converterName: converterName,
      converterImportUri: converterImportUri,
    );
  }

  List<GeneratedOptionValueMetadata<T>> _optionValueList<T extends Object>(DartObject? object) {
    return object
            ?.toListValue()
            ?.map(_optionValueFrom)
            .whereType<GeneratedOptionValueMetadata<T>>()
            .toList() ??
        <GeneratedOptionValueMetadata<T>>[];
  }

  List<GeneratedOptionValueMetadata<String>> _enumOptionValueList(DartObject? object) {
    return _constantOptionValueList(object);
  }

  List<GeneratedOptionValueMetadata<String>> _constantOptionValueList(DartObject? object) {
    return object
            ?.toListValue()
            ?.map(_constantOptionValueFrom)
            .whereType<GeneratedOptionValueMetadata<String>>()
            .toList() ??
        <GeneratedOptionValueMetadata<String>>[];
  }

  List<GeneratedOptionValueMetadata<Map<String, Object?>>> _objectOptionValueList(
    DartObject? object,
  ) {
    return object
            ?.toListValue()
            ?.map(_objectOptionValueFrom)
            .whereType<GeneratedOptionValueMetadata<Map<String, Object?>>>()
            .toList() ??
        <GeneratedOptionValueMetadata<Map<String, Object?>>>[];
  }

  List<GeneratedOptionValueMetadata<Map<String, Object?>>> _mappedObjectOptionValueList(
    DartObject? object,
    Map<String, Object?>? Function(DartObject? object) valueFrom,
  ) {
    return object
            ?.toListValue()
            ?.map((object) => _mappedObjectOptionValueFrom(object, valueFrom))
            .whereType<GeneratedOptionValueMetadata<Map<String, Object?>>>()
            .toList() ??
        <GeneratedOptionValueMetadata<Map<String, Object?>>>[];
  }

  List<GeneratedOptionValueMetadata<int>> _colorOptionValueList(DartObject? object) {
    return object
            ?.toListValue()
            ?.map(_colorOptionValueFrom)
            .whereType<GeneratedOptionValueMetadata<int>>()
            .toList() ??
        <GeneratedOptionValueMetadata<int>>[];
  }

  List<GeneratedOptionValueMetadata<int>> _durationOptionValueList(DartObject? object) {
    return object
            ?.toListValue()
            ?.map(_durationOptionValueFrom)
            .whereType<GeneratedOptionValueMetadata<int>>()
            .toList() ??
        <GeneratedOptionValueMetadata<int>>[];
  }

  List<GeneratedOptionValueMetadata<String>> _iconDataOptionValueList(DartObject? object) {
    return object
            ?.toListValue()
            ?.map(_iconDataOptionValueFrom)
            .whereType<GeneratedOptionValueMetadata<String>>()
            .toList() ??
        <GeneratedOptionValueMetadata<String>>[];
  }

  GeneratedOptionValueMetadata<String>? _constantOptionValueFrom(DartObject? object) {
    if (object == null || object.isNull) {
      return null;
    }

    final value = _constantNameFrom(object.getField('value') ?? object);
    if (value == null) {
      return null;
    }

    return GeneratedOptionValueMetadata<String>(
      value,
      label: object.getField('label')?.toStringValue(),
      description: object.getField('description')?.toStringValue(),
    );
  }

  GeneratedOptionValueMetadata<Map<String, Object?>>? _objectOptionValueFrom(DartObject? object) {
    if (object == null || object.isNull) {
      return null;
    }

    final value = _jsonMapFrom(object.getField('value') ?? object);
    if (value == null) {
      return null;
    }

    return GeneratedOptionValueMetadata<Map<String, Object?>>(
      value,
      label: object.getField('label')?.toStringValue(),
      description: object.getField('description')?.toStringValue(),
    );
  }

  GeneratedOptionValueMetadata<Map<String, Object?>>? _mappedObjectOptionValueFrom(
    DartObject? object,
    Map<String, Object?>? Function(DartObject? object) valueFrom,
  ) {
    if (object == null || object.isNull) {
      return null;
    }

    final value = valueFrom(object.getField('value') ?? object);
    if (value == null) {
      return null;
    }

    return GeneratedOptionValueMetadata<Map<String, Object?>>(
      value,
      label: object.getField('label')?.toStringValue(),
      description: object.getField('description')?.toStringValue(),
    );
  }

  GeneratedOptionValueMetadata<int>? _colorOptionValueFrom(DartObject? object) {
    if (object == null || object.isNull) {
      return null;
    }

    final value = _colorIntFrom(object.getField('value') ?? object);
    if (value == null) {
      return null;
    }

    return GeneratedOptionValueMetadata<int>(
      value,
      label: object.getField('label')?.toStringValue(),
      description: object.getField('description')?.toStringValue(),
    );
  }

  GeneratedOptionValueMetadata<int>? _durationOptionValueFrom(DartObject? object) {
    if (object == null || object.isNull) {
      return null;
    }

    final value = _durationMillisFrom(object.getField('value') ?? object);
    if (value == null) {
      return null;
    }

    return GeneratedOptionValueMetadata<int>(
      value,
      label: object.getField('label')?.toStringValue(),
      description: object.getField('description')?.toStringValue(),
    );
  }

  GeneratedOptionValueMetadata<String>? _iconDataOptionValueFrom(DartObject? object) {
    if (object == null || object.isNull) {
      return null;
    }

    final value = _iconDataStringFrom(object.getField('value') ?? object);
    if (value == null) {
      return null;
    }

    return GeneratedOptionValueMetadata<String>(
      value,
      label: object.getField('label')?.toStringValue(),
      description: object.getField('description')?.toStringValue(),
    );
  }

  GeneratedOptionValueMetadata<Object>? _optionValueFrom(DartObject? object) {
    if (object == null || object.isNull) {
      return null;
    }

    final valueObject = object.getField('value');
    final value = _primitiveValueFrom(valueObject ?? object);
    if (value is! Object) {
      return null;
    }

    return GeneratedOptionValueMetadata<Object>(
      value,
      label: object.getField('label')?.toStringValue(),
      description: object.getField('description')?.toStringValue(),
    );
  }

  Object? _primitiveValueFrom(DartObject? object) {
    if (object == null || object.isNull) {
      return null;
    }

    return object.toBoolValue() ??
        object.toIntValue() ??
        object.toDoubleValue() ??
        object.toStringValue();
  }

  String? _constantNameFrom(DartObject? object) {
    if (object == null || object.isNull) {
      return null;
    }
    return object.variable?.name ?? object.getField('name')?.toStringValue();
  }

  Map<String, Object?>? _jsonMapFrom(DartObject? object) {
    final map = object?.toMapValue();
    if (map == null) {
      return null;
    }

    return <String, Object?>{
      for (final entry in map.entries)
        if (_primitiveValueFrom(entry.key) case final String key) key: _jsonValueFrom(entry.value),
    };
  }

  Object? _jsonValueFrom(DartObject? object) {
    if (object == null || object.isNull) {
      return null;
    }

    final primitive = _primitiveValueFrom(object);
    if (primitive != null) {
      return primitive;
    }

    final list = object.toListValue();
    if (list != null) {
      return list.map(_jsonValueFrom).toList();
    }

    final map = _jsonMapFrom(object);
    if (map != null) {
      return map;
    }

    return null;
  }

  int? _colorIntFrom(DartObject? object) {
    return object?.getField('value')?.toIntValue() ?? object?.toIntValue();
  }

  Map<String, Object?>? _edgeInsetsMapFrom(DartObject? object) {
    if (object == null || object.isNull) {
      return null;
    }
    return <String, Object?>{
      'left': _doubleFrom(object.getField('left')) ?? 0,
      'top': _doubleFrom(object.getField('top')) ?? 0,
      'right': _doubleFrom(object.getField('right')) ?? 0,
      'bottom': _doubleFrom(object.getField('bottom')) ?? 0,
    };
  }

  Map<String, Object?>? _borderRadiusMapFrom(DartObject? object) {
    if (object == null || object.isNull) {
      return null;
    }
    return <String, Object?>{
      'topLeft': _radiusMapFrom(object.getField('topLeft')) ?? _zeroRadiusMap(),
      'topRight': _radiusMapFrom(object.getField('topRight')) ?? _zeroRadiusMap(),
      'bottomLeft': _radiusMapFrom(object.getField('bottomLeft')) ?? _zeroRadiusMap(),
      'bottomRight': _radiusMapFrom(object.getField('bottomRight')) ?? _zeroRadiusMap(),
    };
  }

  Map<String, Object?>? _radiusMapFrom(DartObject? object) {
    if (object == null || object.isNull) {
      return null;
    }
    return <String, Object?>{
      'x': _doubleFrom(object.getField('x')) ?? 0,
      'y': _doubleFrom(object.getField('y')) ?? 0,
    };
  }

  Map<String, Object?> _zeroRadiusMap() {
    return const <String, Object?>{'x': 0.0, 'y': 0.0};
  }

  Map<String, Object?>? _sizeMapFrom(DartObject? object) {
    if (object == null || object.isNull) {
      return null;
    }
    return <String, Object?>{
      'width': _doubleFrom(object.getField('width')) ?? 0,
      'height': _doubleFrom(object.getField('height')) ?? 0,
    };
  }

  int? _durationMillisFrom(DartObject? object) {
    return object?.getField('inMilliseconds')?.toIntValue() ?? object?.toIntValue();
  }

  Map<String, Object?>? _boxConstraintsMapFrom(DartObject? object) {
    if (object == null || object.isNull) {
      return null;
    }
    final encoded = <String, Object?>{
      'minWidth': _doubleFrom(object.getField('minWidth')) ?? 0,
      'minHeight': _doubleFrom(object.getField('minHeight')) ?? 0,
    };
    final maxWidth = _doubleFrom(object.getField('maxWidth'));
    final maxHeight = _doubleFrom(object.getField('maxHeight'));
    if (maxWidth != null && maxWidth.isFinite) {
      encoded['maxWidth'] = maxWidth;
    }
    if (maxHeight != null && maxHeight.isFinite) {
      encoded['maxHeight'] = maxHeight;
    }
    return encoded;
  }

  double? _doubleFrom(DartObject? object) {
    return object?.toDoubleValue() ?? object?.toIntValue()?.toDouble();
  }

  String? _iconDataStringFrom(DartObject? object) {
    final encoded = _iconDataMapFrom(object);
    if (encoded == null) {
      return null;
    }
    return jsonEncode(encoded);
  }

  Map<String, Object?>? _iconDataMapFrom(DartObject? object) {
    if (object == null || object.isNull) {
      return null;
    }

    final codePoint = object.getField('codePoint')?.toIntValue();
    if (codePoint == null) {
      return null;
    }

    final encoded = <String, Object?>{'codePoint': codePoint};
    final fontFamily = object.getField('fontFamily')?.toStringValue();
    final fontPackage = object.getField('fontPackage')?.toStringValue();
    final fontFamilyFallback = _stringList(object.getField('fontFamilyFallback'));

    if (fontFamily != null) {
      encoded['fontFamily'] = fontFamily;
    }
    if (fontPackage != null) {
      encoded['fontPackage'] = fontPackage;
    }
    if (object.getField('matchTextDirection')?.toBoolValue() case true) {
      encoded['matchTextDirection'] = true;
    }
    if (fontFamilyFallback.isNotEmpty) {
      encoded['fontFamilyFallback'] = fontFamilyFallback;
    }

    return encoded;
  }

  String _requiredString(DartObject object, String fieldName) {
    return object.getField(fieldName)?.toStringValue() ??
        (fieldName == 'name' ? object.getField('_name')?.toStringValue() : null) ??
        '';
  }

  String _libraryImportUri(BuildStep buildStep, AssetId asset) {
    return 'package:${buildStep.inputId.package}/${asset.path.substring('lib/'.length)}';
  }

  String? _publicImportUri(String? importUri) {
    if (importUri == null) {
      return null;
    }
    if (importUri.startsWith('package:flutter/src/')) {
      return 'package:flutter/widgets.dart';
    }
    if (importUri.startsWith('package:hippo_ui_flutter/src/')) {
      return 'package:hippo_ui_flutter/hippo_ui_flutter.dart';
    }
    return importUri;
  }

  GeneratedPreviewTargetKind _targetKind(Element element) {
    if (element is ClassElement) {
      return GeneratedPreviewTargetKind.classDeclaration;
    }
    if (element is TopLevelFunctionElement) {
      return element.formalParameters.length <= 1
          ? GeneratedPreviewTargetKind.functionDeclaration
          : GeneratedPreviewTargetKind.other;
    }
    return GeneratedPreviewTargetKind.other;
  }

  bool _targetUsesConfiguration(Element element) {
    return element is TopLevelFunctionElement && element.formalParameters.isNotEmpty;
  }

  bool _createsFlutterPreviewBridge(DartObject annotation, Element element) {
    return element is ClassElement &&
        _isFlutterPreviewAnnotation(annotation) &&
        _isFlutterWidgetClass(element);
  }

  bool _isFlutterPreviewAnnotation(DartObject annotation) {
    final type = annotation.type;
    return type is InterfaceType &&
        _isTypeOrSuperType(type, typeName: 'Preview', libraryUri: _flutterPreviewLibraryUri);
  }

  bool _isFlutterWidgetClass(ClassElement element) {
    return _isTypeOrSuperType(
      element.thisType,
      typeName: 'Widget',
      libraryUri: _flutterWidgetLibraryUri,
    );
  }

  bool _isTypeOrSuperType(InterfaceType type, {required String typeName, required Uri libraryUri}) {
    bool matches(InterfaceType candidate) {
      return candidate.element.displayName == typeName &&
          candidate.element.library.uri == libraryUri;
    }

    return matches(type) || type.allSupertypes.any(matches);
  }
}
