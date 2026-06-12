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
import 'package:hippo_ui_preview/hippo_ui_preview.dart';

import '../addons/alignment_addon.dart';
import '../addons/hitbox_addon.dart';
import '../addons/viewport_addon.dart';
import '../addons/widget_outline_addon.dart';
import 'hippo_ui_preview_grid_builder.dart';
import 'hippo_ui_preview_zoom_builder.dart';

typedef HippoUiPreviewSharedAddonsWidgetBuilder = Widget Function(BuildContext context);

/// Applies shared preview addons around [builder].
final class HippoUiPreviewSharedAddonsBuilder extends StatelessWidget {
  const HippoUiPreviewSharedAddonsBuilder({
    required this.builder,
    this.zoomState,
    this.widgetOutlineState,
    this.gridState,
    this.viewportState,
    this.alignmentState,
    this.hitboxState,
    super.key,
  });

  final ZoomAddonState? zoomState;

  final HippoUiPreviewAddonState? widgetOutlineState;

  final GridAddonState? gridState;

  final ViewportAddonState? viewportState;

  final AlignmentAddonState? alignmentState;

  final HippoUiPreviewAddonState? hitboxState;

  final HippoUiPreviewSharedAddonsWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    Widget child = Builder(builder: builder);

    if (hitboxState != null) {
      child = HippoUiPreviewHitboxBuilder(state: hitboxState, child: child);
    }

    final alignmentState = this.alignmentState;
    if (alignmentState != null) {
      child = Align(
        alignment: alignmentState.alignment,
        child: UnconstrainedBox(child: child),
      );
    }

    final viewportState = this.viewportState;
    if (viewportState != null) {
      child = HippoUiPreviewViewportBuilder(state: viewportState, child: child);
    }

    final gridState = this.gridState;
    if (gridState != null) {
      child = HippoUiPreviewGridBuilder(state: gridState, child: child);
    }

    if (widgetOutlineState != null) {
      child = HippoUiPreviewWidgetOutlineBuilder(state: widgetOutlineState, child: child);
    }

    final zoomState = this.zoomState;
    if (zoomState != null) {
      child = HippoUiPreviewZoomBuilder(state: zoomState, child: child);
    }

    return child;
  }
}
