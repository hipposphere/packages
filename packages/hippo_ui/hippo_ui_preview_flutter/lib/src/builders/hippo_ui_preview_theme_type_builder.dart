/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:hippo_ui_flutter/hippo_ui_flutter.dart';
import 'package:hippo_ui_preview/hippo_ui_preview.dart';

typedef HippoUiPreviewThemeDataBuilder =
    ThemeData Function(BuildContext context, Brightness brightness);

/// Applies the selected preview theme type to [child].
final class HippoUiPreviewThemeTypeBuilder extends StatelessWidget {
  const HippoUiPreviewThemeTypeBuilder({
    required this.state,
    required this.child,
    this.themeBuilder,
    super.key,
  });

  final ThemeTypeAddonState state;

  final HippoUiPreviewThemeDataBuilder? themeBuilder;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = switch (state.themeType) {
      ThemeType.dark => Brightness.dark,
      ThemeType.light => Brightness.light,
      ThemeType.system => MediaQuery.platformBrightnessOf(context),
    };

    return Theme(
      data: themeBuilder?.call(context, brightness) ?? _defaultThemeData(context, brightness),
      child: child,
    );
  }

  ThemeData _defaultThemeData(BuildContext context, Brightness brightness) {
    final theme = Theme.of(context);
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: theme.colorScheme.primary,
        brightness: brightness,
      ),
      useMaterial3: theme.useMaterial3,
    );
  }
}
