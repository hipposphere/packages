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

typedef HippoUiPlaygroundWidgetBuilder =
    Widget Function(
      BuildContext context,
      HippoUiPlaygroundState playgroundState,
      HippoUiPlaygroundConfiguration configuration,
    );

/// Builds the actual Flutter playground widget from the playground controller.
final class HippoUiPlaygroundFlutterBuilder extends StatelessWidget {
  const HippoUiPlaygroundFlutterBuilder({
    required this.playgroundController,
    required this.builder,
    super.key,
  });

  final HippoUiPlaygroundController playgroundController;

  final HippoUiPlaygroundWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return DataSubjectBuilder<HippoUiPlaygroundState>(
      subject: playgroundController.playgroundState,
      builder: (context, playgroundState) {
        return DataSubjectBuilder<HippoUiPlaygroundConfiguration>(
          key: ValueKey(playgroundState.previewDefinition.targetName),
          subject: playgroundState.configuration,
          builder: (context, configuration) {
            return builder(context, playgroundState, configuration);
          },
        );
      },
    );
  }
}
