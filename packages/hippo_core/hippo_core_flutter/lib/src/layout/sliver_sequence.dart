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

/// Empty space along a sliver viewport's main axis.
class SliverSpace extends StatelessWidget {
  final double extent;

  const SliverSpace(this.extent, {super.key}) : assert(extent >= 0);

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final child = switch (constraints.axisDirection) {
          AxisDirection.up || AxisDirection.down => SizedBox(height: extent),
          AxisDirection.left || AxisDirection.right => SizedBox(width: extent),
        };
        return SliverToBoxAdapter(child: child);
      },
    );
  }
}

/// Places real slivers sequentially and optionally separates them with space.
///
/// Unlike a box [Column], this preserves lazy lists, grids, and sliver headers.
class SliverSequence extends StatelessWidget {
  final List<Widget> slivers;
  final double spacing;

  const SliverSequence({super.key, required this.slivers, this.spacing = 0}) : assert(spacing >= 0);

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: _separatedSlivers());
  }

  List<Widget> _separatedSlivers() {
    if (spacing == 0 || slivers.length < 2) return slivers;

    return [
      for (var index = 0; index < slivers.length; index++) ...[
        if (index > 0) SliverSpace(spacing),
        slivers[index],
      ],
    ];
  }
}
