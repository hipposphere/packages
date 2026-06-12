/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

/// Structured folder metadata used by preview apps to organize widget previews.
///
/// This is a catalog model, not an annotation. Preview apps can define their
/// own folder tree from generated preview paths. Use slash-separated paths for
/// hierarchy, for example `Actions` or `Actions/Button`.
class HippoWidgetFolder {
  const HippoWidgetFolder({
    required this.path,
    required this.name,
    this.description,
    this.tags = const <String>[],
    this.sortOrder,
    this.folders = const <HippoWidgetFolder>[],
  });

  /// Stable slash-separated folder path.
  final String path;

  /// Human-readable folder name.
  final String name;

  /// Short description for preview catalogs and review apps.
  final String? description;

  /// Optional search/filter tags for tooling.
  final List<String> tags;

  /// Optional order hint for generated navigation.
  final int? sortOrder;

  /// Nested child folders for structured catalog navigation.
  final List<HippoWidgetFolder> folders;
}
