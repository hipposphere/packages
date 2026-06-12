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
import 'package:hippo_ui_flutter/hippo_ui_flutter.dart';

import '../controllers/hippo_ui_icon_catalog_controller.dart';

typedef HippoUiIconCatalogListWidgetBuilder =
    Widget Function(BuildContext context, List<HippoUiFlutterIconDefinition> icons);

/// Rebuilds with the current filtered icon catalog results.
final class HippoUiIconCatalogListBuilder extends StatelessWidget {
  const HippoUiIconCatalogListBuilder({required this.controller, required this.builder, super.key});

  final HippoUiIconCatalogController controller;

  final HippoUiIconCatalogListWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => builder(context, controller.filteredIcons),
    );
  }
}
