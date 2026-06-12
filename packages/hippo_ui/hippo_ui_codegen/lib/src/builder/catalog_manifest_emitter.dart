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

import 'catalog_metadata.dart';

class CatalogManifestEmitter {
  const CatalogManifestEmitter();

  static const schemaVersion = 1;

  String emit(CatalogMetadata catalog) {
    final json = <String, Object?>{
      'schemaVersion': schemaVersion,
      'previews': catalog.previews.map(_previewJson).toList(growable: false),
    };

    return '${const JsonEncoder.withIndent('  ').convert(json)}\n';
  }

  Map<String, Object?> _previewJson(GeneratedPreviewMetadata preview) {
    final json = <String, Object?>{
      'id': preview.id,
      'targetName': preview.targetName,
      'name': preview.name,
      'path': preview.path,
      'options': preview.options.map(_optionJson).toList(growable: false),
    };

    if (preview.description case final description?) {
      json['description'] = description;
    }
    if (preview.tags.isNotEmpty) {
      json['tags'] = preview.tags;
    }

    return json;
  }

  Map<String, Object?> _optionJson(GeneratedOptionMetadata option) {
    final json = <String, Object?>{'key': option.key, 'type': _optionType(option)};
    if (option.label case final label?) {
      json['label'] = label;
    }
    if (option.description case final description?) {
      json['description'] = description;
    }
    if (option.defaultValue case final defaultValue?) {
      json['defaultValue'] = defaultValue;
    }

    switch (option) {
      case GeneratedIntegerOptionMetadata():
        if (option.min case final min?) {
          json['min'] = min;
        }
        if (option.max case final max?) {
          json['max'] = max;
        }
        if (option.step case final step?) {
          json['step'] = step;
        }
        if (option.values.isNotEmpty) {
          json['values'] = _optionValuesJson(option.values);
        }
      case GeneratedDoubleOptionMetadata():
        if (option.min case final min?) {
          json['min'] = min;
        }
        if (option.max case final max?) {
          json['max'] = max;
        }
        if (option.step case final step?) {
          json['step'] = step;
        }
        if (option.values.isNotEmpty) {
          json['values'] = _optionValuesJson(option.values);
        }
      case GeneratedTextOptionMetadata():
        if (option.values.isNotEmpty) {
          json['values'] = _optionValuesJson(option.values);
        }
      case GeneratedEnumOptionMetadata():
        if (option.enumType case final enumType?) {
          json['enumType'] = enumType;
        }
        if (option.values.isNotEmpty) {
          json['values'] = _optionValuesJson(option.values);
        }
      case GeneratedObjectOptionMetadata():
        if (option.values.isNotEmpty) {
          json['values'] = _optionValuesJson(option.values);
        }
      case GeneratedBooleanOptionMetadata() || GeneratedUnknownOptionMetadata():
        break;
    }

    return json;
  }

  String _optionType(GeneratedOptionMetadata option) {
    return switch (option) {
      GeneratedBooleanOptionMetadata() => 'boolean',
      GeneratedIntegerOptionMetadata() => 'integer',
      GeneratedDoubleOptionMetadata() => 'double',
      GeneratedTextOptionMetadata() => 'text',
      GeneratedEnumOptionMetadata() => 'enum',
      GeneratedObjectOptionMetadata() => 'object',
      GeneratedUnknownOptionMetadata() => 'unknown',
    };
  }

  List<Map<String, Object?>> _optionValuesJson<T extends Object>(
    List<GeneratedOptionValueMetadata<T>> values,
  ) {
    return values
        .map((value) {
          final json = <String, Object?>{'value': value.value};
          if (value.label case final label?) {
            json['label'] = label;
          }
          if (value.description case final description?) {
            json['description'] = description;
          }
          return json;
        })
        .toList(growable: false);
  }
}
