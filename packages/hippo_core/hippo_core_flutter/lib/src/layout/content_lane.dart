/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'content_layout.dart';

/// A centered, width-limited content lane.
///
/// Use [ContentLane.box] in box layouts and [ContentLane.sliver] in vertical
/// sliver layouts. Both variants apply the same [ContentLayout] policy while
/// keeping Flutter's box and sliver protocols explicit.
abstract class ContentLane extends StatelessWidget {
  const ContentLane({super.key});

  const factory ContentLane.box({Key? key, required Widget child, ContentLayout layout}) =
      BoxContentLane;

  const factory ContentLane.sliver({Key? key, required Widget sliver, ContentLayout layout}) =
      SliverContentLane;
}

/// The box-layout implementation of [ContentLane].
class BoxContentLane extends ContentLane {
  final Widget child;
  final ContentLayout layout;

  const BoxContentLane({super.key, required this.child, this.layout = const ContentLayout()});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: layout.gutters,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: layout.maxWidth),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}

/// The vertical sliver-layout implementation of [ContentLane].
class SliverContentLane extends ContentLane {
  final Widget sliver;
  final ContentLayout layout;

  const SliverContentLane({super.key, required this.sliver, this.layout = const ContentLayout()});

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        assert(
          constraints.axisDirection == AxisDirection.down ||
              constraints.axisDirection == AxisDirection.up,
          'SliverContentLane only supports vertical scroll views.',
        );

        final gutters = layout.gutters.resolve(Directionality.of(context));
        final availableWidth = math.max(0.0, constraints.crossAxisExtent - gutters.horizontal);
        final extraGutter = math.max(0.0, (availableWidth - layout.maxWidth) / 2);

        return SliverPadding(
          padding: gutters.add(EdgeInsets.symmetric(horizontal: extraGutter)),
          sliver: sliver,
        );
      },
    );
  }
}
