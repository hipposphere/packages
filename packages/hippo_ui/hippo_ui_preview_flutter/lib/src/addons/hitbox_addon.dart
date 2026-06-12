/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:flutter/rendering.dart' as rendering;
import 'package:flutter/widgets.dart';
import 'package:hippo_ui_preview/hippo_ui_preview.dart';

/// Flutter preview addon configuration for hit-test area overlays.
final class HitboxAddon extends HippoUiPreviewAddon<HippoUiPreviewConfiguredAddonState> {
  const HitboxAddon()
    : super(
        id: addonId,
        label: 'Hitboxes',
        configurationOptions: const [
          .boolean(key: 'enabled', label: 'Enabled', defaultValue: false),
        ],
      );

  static const addonId = 'hitboxes';

  static const enabledKey = 'enabled';

  @override
  HippoUiPreviewConfiguredAddonState get defaultState {
    return const HippoUiPreviewConfiguredAddonState(
      addonId: addonId,
      configuration: <String, Object?>{enabledKey: false},
    );
  }

  @override
  HippoUiPreviewConfiguredAddonState decodeState(Object? json) {
    return HippoUiPreviewConfiguredAddonState.fromJson(addonId, json);
  }

  static bool enabledFromState(HippoUiPreviewAddonState? state) {
    if (state is! HippoUiPreviewConfiguredAddonState) {
      return false;
    }
    return state.configuration[enabledKey] as bool? ?? false;
  }

  static HippoUiPreviewConfiguredAddonState stateFor({required bool enabled}) {
    return HippoUiPreviewConfiguredAddonState(
      addonId: addonId,
      configuration: <String, Object?>{enabledKey: enabled},
    );
  }
}

/// Paints tappable render box bounds over [child].
final class HippoUiPreviewHitboxBuilder extends StatefulWidget {
  const HippoUiPreviewHitboxBuilder({
    required this.state,
    required this.child,
    this.color = const Color(0xffd92d20),
    this.strokeWidth = 1,
    super.key,
  });

  final HippoUiPreviewAddonState? state;

  final Color color;

  final double strokeWidth;

  final Widget child;

  @override
  State<HippoUiPreviewHitboxBuilder> createState() => _HippoUiPreviewHitboxBuilderState();
}

final class _HippoUiPreviewHitboxBuilderState extends State<HippoUiPreviewHitboxBuilder> {
  final GlobalKey _childKey = GlobalKey();

  List<Rect> _hitboxes = const <Rect>[];

  @override
  void initState() {
    super.initState();
    _scheduleHitboxCollection();
  }

  @override
  void didUpdateWidget(HippoUiPreviewHitboxBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleHitboxCollection();
  }

  @override
  Widget build(BuildContext context) {
    if (!HitboxAddon.enabledFromState(widget.state)) {
      return widget.child;
    }

    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        KeyedSubtree(key: _childKey, child: widget.child),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              foregroundPainter: _HitboxPainter(
                hitboxes: _hitboxes,
                color: widget.color,
                strokeWidth: widget.strokeWidth,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _scheduleHitboxCollection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !HitboxAddon.enabledFromState(widget.state)) {
        return;
      }
      _collectHitboxes();
    });
  }

  void _collectHitboxes() {
    final rootObject = _childKey.currentContext?.findRenderObject();
    if (rootObject is! rendering.RenderBox || !rootObject.hasSize) {
      return;
    }

    final hitboxes = <Rect>[];
    void visit(rendering.RenderObject object) {
      if (object is rendering.RenderBox &&
          object.hasSize &&
          object.size.width > 0 &&
          object.size.height > 0) {
        if (_isTappable(object)) {
          _addUniqueRect(
            hitboxes,
            rendering.MatrixUtils.transformRect(
              object.getTransformTo(rootObject),
              object.paintBounds,
            ),
          );
        }
      }
      object.visitChildren(visit);
    }

    visit(rootObject);
    if (mounted && !_rectListsEqual(_hitboxes, hitboxes)) {
      setState(() {
        _hitboxes = hitboxes;
      });
    }
  }

  bool _isTappable(rendering.RenderBox box) {
    if (box is rendering.RenderSemanticsGestureHandler) {
      return box.onTap != null || box.onLongPress != null;
    }

    if (box is rendering.RenderPointerListener) {
      return box.onPointerDown != null;
    }

    return false;
  }

  void _addUniqueRect(List<Rect> rects, Rect rect) {
    if (rects.contains(rect)) {
      return;
    }
    rects.add(rect);
  }

  bool _rectListsEqual(List<Rect> a, List<Rect> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) {
        return false;
      }
    }
    return true;
  }
}

final class _HitboxPainter extends CustomPainter {
  const _HitboxPainter({required this.hitboxes, required this.color, required this.strokeWidth});

  final List<Rect> hitboxes;

  final Color color;

  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final hitbox in hitboxes) {
      canvas.drawRect(hitbox, paint);
    }
  }

  @override
  bool shouldRepaint(_HitboxPainter oldDelegate) {
    return hitboxes != oldDelegate.hitboxes ||
        color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}
