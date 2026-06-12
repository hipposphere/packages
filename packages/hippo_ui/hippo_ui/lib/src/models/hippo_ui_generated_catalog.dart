/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'hippo_ui_option_converter.dart';

typedef HippoUiGeneratedPreviewBuilder = Object? Function(Map<String, Object?> configuration);

/// Generated preview metadata emitted by `hippo_ui_codegen`.
class HippoUiGeneratedPreview {
  const HippoUiGeneratedPreview({
    required this.id,
    required this.targetName,
    required this.name,
    required this.path,
    this.description,
    this.options = const [],
    this.optionConverters = const [],
    this.builder,
    this.tags = const [],
  });

  /// Stable id for deep links, persisted sessions, and external reports.
  final String id;

  /// Name of the annotated declaration.
  final String targetName;

  final String name;

  final String path;

  final String? description;

  final List<HippoUiGeneratedOption> options;

  final List<HippoUiGeneratedOptionConverter> optionConverters;

  final HippoUiGeneratedPreviewBuilder? builder;

  final List<String> tags;

  Object? build(Map<String, Object?> configuration) {
    return builder?.call(configuration);
  }
}

/// Generated runtime converter metadata for a preview option.
class HippoUiGeneratedOptionConverter<T> {
  const HippoUiGeneratedOptionConverter({required this.optionKey, required this.converter});

  final String optionKey;

  final HippoUiOptionConverter<T> converter;

  T convert(Object? value) {
    return converter.convert(value);
  }
}

/// Base type for generated preview option metadata.
sealed class HippoUiGeneratedOption {
  const HippoUiGeneratedOption({
    required this.key,
    this.label,
    this.description,
    this.defaultValue,
  });

  final String key;

  final String? label;

  final String? description;

  final Object? defaultValue;
}

final class HippoUiGeneratedBooleanOption extends HippoUiGeneratedOption {
  const HippoUiGeneratedBooleanOption({
    required super.key,
    super.label,
    super.description,
    bool super.defaultValue = false,
  });

  @override
  bool get defaultValue => super.defaultValue as bool;
}

final class HippoUiGeneratedIntegerOption extends HippoUiGeneratedOption {
  const HippoUiGeneratedIntegerOption({
    required super.key,
    super.label,
    super.description,
    int super.defaultValue = 0,
    this.min,
    this.max,
    this.step,
    this.values = const [],
  });

  @override
  int get defaultValue => super.defaultValue as int;

  final int? min;

  final int? max;

  final int? step;

  final List<HippoUiGeneratedOptionValue<int>> values;
}

final class HippoUiGeneratedDoubleOption extends HippoUiGeneratedOption {
  const HippoUiGeneratedDoubleOption({
    required super.key,
    super.label,
    super.description,
    double super.defaultValue = 0,
    this.min,
    this.max,
    this.step,
    this.values = const [],
  });

  @override
  double get defaultValue => super.defaultValue as double;

  final double? min;

  final double? max;

  final double? step;

  final List<HippoUiGeneratedOptionValue<double>> values;
}

final class HippoUiGeneratedTextOption extends HippoUiGeneratedOption {
  const HippoUiGeneratedTextOption({
    required super.key,
    super.label,
    super.description,
    String super.defaultValue = '',
    this.values = const [],
  });

  @override
  String get defaultValue => super.defaultValue as String;

  final List<HippoUiGeneratedOptionValue<String>> values;
}

final class HippoUiGeneratedEnumOption extends HippoUiGeneratedOption {
  const HippoUiGeneratedEnumOption({
    required super.key,
    required String super.defaultValue,
    super.label,
    super.description,
    this.enumType,
    this.values = const [],
  });

  @override
  String get defaultValue => super.defaultValue as String;

  final String? enumType;

  final List<HippoUiGeneratedOptionValue<String>> values;
}

final class HippoUiGeneratedObjectOption extends HippoUiGeneratedOption {
  const HippoUiGeneratedObjectOption({
    required super.key,
    super.label,
    super.description,
    Map<String, Object?> super.defaultValue = const <String, Object?>{},
    this.values = const [],
  });

  @override
  Map<String, Object?> get defaultValue => super.defaultValue as Map<String, Object?>;

  final List<HippoUiGeneratedOptionValue<Map<String, Object?>>> values;
}

final class HippoUiGeneratedUnknownOption extends HippoUiGeneratedOption {
  const HippoUiGeneratedUnknownOption({
    required super.key,
    super.label,
    super.description,
    super.defaultValue,
  });
}

/// Generated selectable option value metadata.
class HippoUiGeneratedOptionValue<T extends Object> {
  const HippoUiGeneratedOptionValue({required this.value, this.label, this.description});

  final T value;

  final String? label;

  final String? description;
}

/// Query helper around a generated preview list.
final class HippoUiCatalog {
  const HippoUiCatalog(this.previews);

  final List<HippoUiGeneratedPreview> previews;

  bool get isEmpty => previews.isEmpty;

  bool get isNotEmpty => previews.isNotEmpty;

  HippoUiGeneratedPreview? previewById(String id) {
    for (final preview in previews) {
      if (preview.id == id) {
        return preview;
      }
    }
    return null;
  }

  List<HippoUiGeneratedPreview> previewsByPath(String path) {
    return previews.where((preview) => preview.path == path).toList(growable: false);
  }

  List<HippoUiGeneratedPreview> previewsInPath(String path) {
    final prefix = path.endsWith('/') ? path : '$path/';
    return previews
        .where((preview) => preview.path == path || preview.path.startsWith(prefix))
        .toList(growable: false);
  }

  List<HippoUiGeneratedPreview> previewsWithTag(String tag) {
    return previews.where((preview) => preview.tags.contains(tag)).toList(growable: false);
  }

  List<HippoUiGeneratedPreview> search(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return sortedPreviews();
    }

    return previews
        .where((preview) {
          return preview.id.toLowerCase().contains(normalizedQuery) ||
              preview.name.toLowerCase().contains(normalizedQuery) ||
              preview.path.toLowerCase().contains(normalizedQuery) ||
              preview.targetName.toLowerCase().contains(normalizedQuery) ||
              (preview.description?.toLowerCase().contains(normalizedQuery) ?? false) ||
              preview.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));
        })
        .toList(growable: false);
  }

  List<HippoUiGeneratedPreview> sortedPreviews() {
    return <HippoUiGeneratedPreview>[...previews]..sort((a, b) {
      final pathComparison = a.path.compareTo(b.path);
      if (pathComparison != 0) {
        return pathComparison;
      }
      return a.name.compareTo(b.name);
    });
  }

  HippoUiCatalogFolder get rootFolder {
    final root = HippoUiCatalogFolder.root();
    for (final preview in sortedPreviews()) {
      root.addPreview(preview);
    }
    root.sort();
    return root;
  }
}

/// Folder node for generated preview catalog navigation.
final class HippoUiCatalogFolder {
  HippoUiCatalogFolder({required this.name, required this.path});

  HippoUiCatalogFolder.root() : name = '', path = '';

  final String name;

  final String path;

  final Map<String, HippoUiCatalogFolder> children = <String, HippoUiCatalogFolder>{};

  final List<HippoUiGeneratedPreview> previews = <HippoUiGeneratedPreview>[];

  void addPreview(HippoUiGeneratedPreview preview) {
    final segments = preview.path.split('/').where((segment) => segment.isNotEmpty).toList();
    if (segments.isEmpty) {
      previews.add(preview);
      return;
    }

    var folder = this;
    for (final segment in segments) {
      final childPath = folder.path.isEmpty ? segment : '${folder.path}/$segment';
      folder = folder.children.putIfAbsent(
        segment,
        () => HippoUiCatalogFolder(name: segment, path: childPath),
      );
    }
    folder.previews.add(preview);
  }

  void sort() {
    previews.sort((a, b) => a.name.compareTo(b.name));
    final sortedChildren = children.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    children
      ..clear()
      ..addEntries(sortedChildren);
    for (final child in children.values) {
      child.sort();
    }
  }
}
