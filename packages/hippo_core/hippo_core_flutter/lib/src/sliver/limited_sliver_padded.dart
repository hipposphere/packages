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

import '../layout/content_lane.dart';
import '../layout/content_layout.dart';

class LimitedSliverPadded extends StatelessWidget {
  final Widget sliver;
  final double maxWidth;
  final EdgeInsets padding;

  const LimitedSliverPadded({
    super.key,
    required this.sliver,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.maxWidth = 800,
  });

  @override
  Widget build(BuildContext context) {
    return ContentLane.sliver(
      layout: ContentLayout(maxWidth: maxWidth, gutters: padding),
      sliver: sliver,
    );
  }
}
