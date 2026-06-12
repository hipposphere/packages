/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import '../models/hippo_ui_option.dart';

/// Framework-neutral metadata contract for a hippo-ui widget preview target.
///
/// Keep values const-friendly and framework-neutral so analyzer/build tooling
/// can read metadata without loading Flutter.
abstract interface class HippoWidgetPreviewMetadata {
  /// Optional stable id for this preview.
  ///
  /// When omitted, code generation derives one from the target import URI and
  /// declaration name.
  String? get id;

  /// Human-readable display name for the previewed API.
  String get name;

  /// Stable catalog path owned by the package declaring the preview.
  ///
  /// Preview apps can use this path to place the preview into their own folder
  /// structure. Use slash-separated paths for hierarchy, for example
  /// `Actions/Button`.
  String get path;

  /// Short description for documentation and generated catalogs.
  String? get description;

  /// Optional search/filter tags for tooling.
  List<String> get tags;
}

/// Source annotation used by tooling to discover a hippo-ui widget preview target.
class HippoWidgetPreview implements HippoWidgetPreviewMetadata {
  const HippoWidgetPreview({
    this.id,
    required this.name,
    required this.path,
    this.description,
    this.tags = const <String>[],
  });

  /// Optional stable id for deep links, persisted sessions, and reports.
  @override
  final String? id;

  /// Human-readable display name for the previewed API.
  @override
  final String name;

  /// Stable catalog path owned by the package declaring the preview.
  ///
  /// Preview apps can use this path to place the preview into their own folder
  /// structure. Use slash-separated paths for hierarchy, for example
  /// `Actions/Button`.
  @override
  final String path;

  /// Short description for documentation and generated catalogs.
  @override
  final String? description;

  /// Optional search/filter tags for tooling.
  @override
  final List<String> tags;
}

/// Marks a constructor parameter as configurable in generated previews.
class HippoWidgetPreviewField {
  const HippoWidgetPreviewField(this.option);

  final HippoUiOption option;
}
