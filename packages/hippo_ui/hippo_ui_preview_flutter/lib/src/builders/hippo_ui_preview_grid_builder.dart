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

/// Applies the selected preview grid overlay to [child].
final class HippoUiPreviewGridBuilder extends StatelessWidget {
  const HippoUiPreviewGridBuilder({
    required this.state,
    required this.child,
    this.color = const Color(0x24000000),
    super.key,
  });

  final GridAddonState state;

  final Color color;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!state.enabled) {
      return child;
    }

    return CustomPaint(
      foregroundPainter: _PreviewGridPainter(size: state.size, color: color),
      child: child,
    );
  }
}

final class _PreviewGridPainter extends CustomPainter {
  const _PreviewGridPainter({required this.size, required this.color});

  final double size;

  final Color color;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    if (size <= 0) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (var x = 0.0; x <= canvasSize.width; x += size) {
      canvas.drawLine(Offset(x, 0), Offset(x, canvasSize.height), paint);
    }
    for (var y = 0.0; y <= canvasSize.height; y += size) {
      canvas.drawLine(Offset(0, y), Offset(canvasSize.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_PreviewGridPainter oldDelegate) {
    return size != oldDelegate.size || color != oldDelegate.color;
  }
}
