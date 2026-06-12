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
import 'package:hippo_core_flutter/hippo_core_flutter.dart';
import 'package:hippo_ui_preview/hippo_ui_preview.dart';

typedef HippoUiPreviewWidgetBuilder =
    Widget Function(BuildContext context, HippoUiPreviewEnvironmentState environmentState);

/// Builds Flutter preview chrome from the current preview environment state.
final class HippoUiPreviewEnvironmentFlutterBuilder extends StatelessWidget {
  const HippoUiPreviewEnvironmentFlutterBuilder({
    required this.controller,
    required this.builder,
    super.key,
  });

  final HippoUiPreviewEnvironmentController controller;

  final HippoUiPreviewWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return DataSubjectBuilder<HippoUiPreviewEnvironmentState?>(
      subject: controller.environmentState,
      builder: (context, state) {
        final environmentState = state ?? HippoUiPreviewEnvironmentState.empty;
        return builder(context, environmentState);
      },
    );
  }
}
