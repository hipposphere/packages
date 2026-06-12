/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

final class CatalogMetadata {
  const CatalogMetadata({this.previews = const <GeneratedPreviewMetadata>[]});

  final List<GeneratedPreviewMetadata> previews;
}

final class GeneratedPreviewMetadata {
  const GeneratedPreviewMetadata({
    required this.id,
    required this.targetName,
    required this.targetImportUri,
    required this.targetKind,
    required this.name,
    required this.path,
    this.description,
    this.options = const <GeneratedOptionMetadata>[],
    this.optionConverters = const <GeneratedOptionConverterMetadata>[],
    this.tags = const <String>[],
  });

  final String id;

  final String targetName;

  final String targetImportUri;

  final GeneratedPreviewTargetKind targetKind;

  final String name;

  final String path;

  final String? description;

  final List<GeneratedOptionMetadata> options;

  final List<GeneratedOptionConverterMetadata> optionConverters;

  final List<String> tags;
}

enum GeneratedPreviewTargetKind { classDeclaration, functionDeclaration, other }

final class GeneratedOptionConverterMetadata {
  const GeneratedOptionConverterMetadata({
    required this.optionKey,
    required this.converterName,
    required this.converterImportUri,
  });

  final String optionKey;

  final String converterName;

  final String converterImportUri;
}

sealed class GeneratedOptionMetadata {
  const GeneratedOptionMetadata({
    required this.key,
    this.label,
    this.description,
    this.defaultValue,
    this.converter,
  });

  final String key;

  final String? label;

  final String? description;

  final Object? defaultValue;

  final GeneratedOptionConverterMetadata? converter;
}

final class GeneratedBooleanOptionMetadata extends GeneratedOptionMetadata {
  const GeneratedBooleanOptionMetadata({
    required super.key,
    super.label,
    super.description,
    bool super.defaultValue = false,
    super.converter,
  });
}

final class GeneratedIntegerOptionMetadata extends GeneratedOptionMetadata {
  const GeneratedIntegerOptionMetadata({
    required super.key,
    super.label,
    super.description,
    int super.defaultValue = 0,
    this.min,
    this.max,
    this.step,
    this.values = const <GeneratedOptionValueMetadata<int>>[],
    super.converter,
  });

  final int? min;

  final int? max;

  final int? step;

  final List<GeneratedOptionValueMetadata<int>> values;
}

final class GeneratedDoubleOptionMetadata extends GeneratedOptionMetadata {
  const GeneratedDoubleOptionMetadata({
    required super.key,
    super.label,
    super.description,
    double super.defaultValue = 0,
    this.min,
    this.max,
    this.step,
    this.values = const <GeneratedOptionValueMetadata<double>>[],
    super.converter,
  });

  final double? min;

  final double? max;

  final double? step;

  final List<GeneratedOptionValueMetadata<double>> values;
}

final class GeneratedTextOptionMetadata extends GeneratedOptionMetadata {
  const GeneratedTextOptionMetadata({
    required super.key,
    super.label,
    super.description,
    String super.defaultValue = '',
    this.values = const <GeneratedOptionValueMetadata<String>>[],
    super.converter,
  });

  final List<GeneratedOptionValueMetadata<String>> values;
}

final class GeneratedEnumOptionMetadata extends GeneratedOptionMetadata {
  const GeneratedEnumOptionMetadata({
    required super.key,
    required String super.defaultValue,
    super.label,
    super.description,
    this.enumType,
    this.enumImportUri,
    this.values = const <GeneratedOptionValueMetadata<String>>[],
    super.converter,
  });

  final String? enumType;

  final String? enumImportUri;

  final List<GeneratedOptionValueMetadata<String>> values;
}

final class GeneratedObjectOptionMetadata extends GeneratedOptionMetadata {
  const GeneratedObjectOptionMetadata({
    required super.key,
    super.label,
    super.description,
    Map<String, Object?> super.defaultValue = const <String, Object?>{},
    this.values = const <GeneratedOptionValueMetadata<Map<String, Object?>>>[],
    super.converter,
  });

  final List<GeneratedOptionValueMetadata<Map<String, Object?>>> values;
}

final class GeneratedUnknownOptionMetadata extends GeneratedOptionMetadata {
  const GeneratedUnknownOptionMetadata({
    required super.key,
    super.label,
    super.description,
    super.defaultValue,
    super.converter,
  });
}

final class GeneratedOptionValueMetadata<T extends Object> {
  const GeneratedOptionValueMetadata(this.value, {this.label, this.description});

  final T value;

  final String? label;

  final String? description;
}
