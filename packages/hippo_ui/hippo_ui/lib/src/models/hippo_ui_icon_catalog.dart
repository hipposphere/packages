/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

/// Framework-neutral icon metadata for UI catalogs and documentation.
class HippoUiIconDefinition {
  const HippoUiIconDefinition({
    required this.id,
    required this.name,
    required this.path,
    this.description,
    this.tags = const <String>[],
    this.variants = const <HippoUiIconVariantDefinition>[],
  });

  /// Stable machine-readable identifier, for example `check` or `nav.arrowLeft`.
  final String id;

  /// Human-readable icon name for catalog UIs.
  final String name;

  /// Slash-separated catalog path, for example `Actions` or `Navigation`.
  final String path;

  /// Optional short description for docs, search, or generated catalogs.
  final String? description;

  /// Optional search/filter tags.
  final List<String> tags;

  /// Available visual variants for this icon.
  final List<HippoUiIconVariantDefinition> variants;
}

/// Framework-neutral metadata for one visual variant of an icon.
class HippoUiIconVariantDefinition {
  const HippoUiIconVariantDefinition({
    required this.id,
    required this.label,
    this.style,
    this.colorMode = HippoUiIconColorMode.currentColor,
    this.tags = const <String>[],
  });

  /// Stable variant identifier, for example `outline`, `filled`, or `colored`.
  final String id;

  /// Human-readable label for catalog UIs.
  final String label;

  /// Optional high-level visual style classification.
  final HippoUiIconStyle? style;

  /// Describes how this variant is expected to receive color.
  final HippoUiIconColorMode colorMode;

  /// Optional variant-specific search/filter tags.
  final List<String> tags;
}

/// Common visual style groups for icons.
enum HippoUiIconStyle { outline, filled, rounded, sharp, duotone, colored }

/// Common icon color behavior groups.
enum HippoUiIconColorMode {
  /// The icon is intended to use the ambient text/icon color.
  currentColor,

  /// The icon expects a single explicit color.
  monochrome,

  /// The icon contains more than one color or manages its own palette.
  multicolor,
}
