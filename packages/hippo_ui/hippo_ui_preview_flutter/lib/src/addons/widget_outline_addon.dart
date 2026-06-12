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

/// Flutter preview addon configuration for render box outline overlays.
final class WidgetOutlineAddon extends HippoUiPreviewAddon<HippoUiPreviewConfiguredAddonState> {
  const WidgetOutlineAddon()
    : super(
        id: addonId,
        label: 'Widget outlines',
        configurationOptions: const [
          .boolean(key: 'enabled', label: 'Enabled', defaultValue: false),
        ],
      );

  static const addonId = 'widgetOutlines';

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

/// Paints render box bounds over [child].
final class HippoUiPreviewWidgetOutlineBuilder extends StatefulWidget {
  const HippoUiPreviewWidgetOutlineBuilder({
    required this.state,
    required this.child,
    this.color = const Color(0xff1570ef),
    this.strokeWidth = 1,
    super.key,
  });

  final HippoUiPreviewAddonState? state;

  final Color color;

  final double strokeWidth;

  final Widget child;

  @override
  State<HippoUiPreviewWidgetOutlineBuilder> createState() =>
      _HippoUiPreviewWidgetOutlineBuilderState();
}

final class _HippoUiPreviewWidgetOutlineBuilderState
    extends State<HippoUiPreviewWidgetOutlineBuilder> {
  final GlobalKey _childKey = GlobalKey();

  List<Rect> _outlines = const <Rect>[];

  @override
  void initState() {
    super.initState();
    _scheduleOutlineCollection();
  }

  @override
  void didUpdateWidget(HippoUiPreviewWidgetOutlineBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleOutlineCollection();
  }

  @override
  Widget build(BuildContext context) {
    if (!WidgetOutlineAddon.enabledFromState(widget.state)) {
      return widget.child;
    }

    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        KeyedSubtree(key: _childKey, child: widget.child),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              foregroundPainter: _WidgetOutlinePainter(
                outlines: _outlines,
                color: widget.color,
                strokeWidth: widget.strokeWidth,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _scheduleOutlineCollection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !WidgetOutlineAddon.enabledFromState(widget.state)) {
        return;
      }
      _collectOutlines();
    });
  }

  void _collectOutlines() {
    final rootObject = _childKey.currentContext?.findRenderObject();
    if (rootObject is! rendering.RenderBox || !rootObject.hasSize) {
      return;
    }

    final outlines = <Rect>[];
    void visit(rendering.RenderObject object) {
      if (object is rendering.RenderBox &&
          object.hasSize &&
          object.size.width > 0 &&
          object.size.height > 0) {
        outlines.add(
          rendering.MatrixUtils.transformRect(
            object.getTransformTo(rootObject),
            object.paintBounds,
          ),
        );
      }
      object.visitChildren(visit);
    }

    visit(rootObject);
    if (mounted && !_rectListsEqual(_outlines, outlines)) {
      setState(() {
        _outlines = outlines;
      });
    }
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

final class _WidgetOutlinePainter extends CustomPainter {
  const _WidgetOutlinePainter({
    required this.outlines,
    required this.color,
    required this.strokeWidth,
  });

  final List<Rect> outlines;

  final Color color;

  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final outline in outlines) {
      canvas.drawRect(outline, paint);
    }
  }

  @override
  bool shouldRepaint(_WidgetOutlinePainter oldDelegate) {
    return outlines != oldDelegate.outlines ||
        color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}
