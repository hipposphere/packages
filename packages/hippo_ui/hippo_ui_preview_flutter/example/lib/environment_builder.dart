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
import 'package:hippo_ui/hippo_ui.dart';
import 'package:hippo_ui_preview_flutter/hippo_ui_preview_flutter.dart';

typedef PreviewEnvironmentWidgetBuilder =
    Widget Function(BuildContext context, PreviewEnvironment environment);

final class PreviewEnvironmentBuilder extends StatelessWidget {
  const PreviewEnvironmentBuilder({
    required this.environmentController,
    required this.builder,
    super.key,
  });

  final HippoUiPreviewEnvironmentController environmentController;

  final PreviewEnvironmentWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return HippoUiPreviewEnvironmentFlutterBuilder(
      controller: environmentController,
      builder: (context, environmentState) {
        return builder(
          context,
          PreviewEnvironment(controller: environmentController, state: environmentState),
        );
      },
    );
  }
}

final class PreviewEnvironment {
  const PreviewEnvironment({required this.controller, required this.state});

  final HippoUiPreviewEnvironmentController controller;

  final HippoUiPreviewEnvironmentState state;

  LocaleAddon get localeAddon {
    return LocaleAddon(
      defaultLocale: const Locale('en'),
      supportedLocales: const <Locale>[Locale('en'), Locale('de'), Locale('fr')],
    );
  }

  ThemeTypeAddonState get themeTypeState {
    return state.addonStates[ThemeTypeAddon.addonId] as ThemeTypeAddonState? ??
        const ThemeTypeAddonState();
  }

  HippoUiPreviewAddonState? get hitboxState {
    return state.addonStates[HitboxAddon.addonId];
  }

  HippoUiPreviewAddonState? get widgetOutlineState {
    return state.addonStates[WidgetOutlineAddon.addonId];
  }

  Locale get locale {
    return localeAddon.localeFromState(state.addonStates[LocaleAddon.addonId]);
  }

  GridAddonState get gridState {
    return state.addonStates[GridAddon.addonId] as GridAddonState? ?? const GridAddonState();
  }

  ZoomAddonState get zoomState {
    return state.addonStates[ZoomAddon.addonId] as ZoomAddonState? ?? const ZoomAddonState();
  }

  AlignmentAddonState get alignmentState {
    return state.addonStates[AlignmentAddon.addonId] as AlignmentAddonState? ??
        const AlignmentAddonState();
  }

  ViewportAddonState get viewportState {
    return state.addonStates[ViewportAddon.addonId] as ViewportAddonState? ??
        const ViewportAddonState();
  }

  Widget wrapPreview(WidgetBuilder builder) {
    return HippoUiPreviewThemeTypeBuilder(
      state: themeTypeState,
      child: HippoUiPreviewLocaleBuilder(
        addon: localeAddon,
        state: state.addonStates[LocaleAddon.addonId],
        child: HippoUiPreviewSharedAddonsBuilder(
          zoomState: zoomState,
          widgetOutlineState: widgetOutlineState,
          gridState: gridState,
          viewportState: viewportState,
          alignmentState: alignmentState,
          hitboxState: hitboxState,
          builder: builder,
        ),
      ),
    );
  }

  Future<void> updateThemeType(ThemeType themeType) {
    return controller.updateAddonState(themeTypeState.copyWith(themeType: themeType));
  }

  Future<void> updateHitboxesEnabled(bool enabled) {
    return controller.updateAddonState(HitboxAddon.stateFor(enabled: enabled));
  }

  Future<void> updateWidgetOutlinesEnabled(bool enabled) {
    return controller.updateAddonState(WidgetOutlineAddon.stateFor(enabled: enabled));
  }

  Future<void> updateLocale(Locale locale) {
    return controller.updateAddonState(localeAddon.stateFor(locale));
  }

  Future<void> updateGridEnabled(bool enabled) {
    return controller.updateAddonState(gridState.copyWith(enabled: enabled));
  }

  Future<void> updateGridSize(double size) {
    return controller.updateAddonState(gridState.copyWith(size: size));
  }

  Future<void> updateZoomScale(double scale) {
    return controller.updateAddonState(zoomState.copyWith(scale: scale));
  }

  Future<void> updateAlignment(Alignment alignment) {
    return controller.updateAddonState(alignmentState.copyWith(alignment: alignment));
  }

  Future<void> updateViewport(HippoUiPreviewViewport viewport) {
    return controller.updateAddonState(viewportState.copyWith(viewport: viewport));
  }
}
