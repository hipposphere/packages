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

/// Applies the selected preview zoom to [child].
final class HippoUiPreviewZoomBuilder extends StatelessWidget {
  const HippoUiPreviewZoomBuilder({
    required this.state,
    required this.child,
    this.alignment = Alignment.center,
    super.key,
  });

  final ZoomAddonState state;

  final AlignmentGeometry alignment;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(scale: state.scale, alignment: alignment, child: child);
  }
}
