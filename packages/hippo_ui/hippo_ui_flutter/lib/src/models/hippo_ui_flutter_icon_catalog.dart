/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:flutter/widgets.dart';
import 'package:hippo_ui/hippo_ui.dart';

typedef HippoUiFlutterIconVariantBuilder =
    Widget Function(BuildContext context, HippoUiFlutterIconStyle style);

/// Flutter-renderable icon metadata for UI catalogs.
class HippoUiFlutterIconDefinition {
  const HippoUiFlutterIconDefinition({required this.definition, required this.variants});

  /// Framework-neutral icon metadata shared with non-Flutter tooling.
  final HippoUiIconDefinition definition;

  /// Renderers keyed by [HippoUiIconVariantDefinition.id].
  final Map<String, HippoUiFlutterIconVariant> variants;

  HippoUiFlutterIconVariant? variant(String variantId) {
    return variants[variantId];
  }
}

/// Flutter renderer for one icon variant.
class HippoUiFlutterIconVariant {
  const HippoUiFlutterIconVariant({required this.builder});

  final HippoUiFlutterIconVariantBuilder builder;

  Widget build(BuildContext context, HippoUiFlutterIconStyle style) {
    return builder(context, style);
  }
}

/// Runtime rendering options for Flutter icon catalogs.
class HippoUiFlutterIconStyle {
  const HippoUiFlutterIconStyle({this.size = 24, this.color});

  final double size;

  final Color? color;
}
