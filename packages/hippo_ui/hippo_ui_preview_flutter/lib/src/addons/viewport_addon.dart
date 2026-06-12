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
import 'package:hippo_ui_preview/hippo_ui_preview.dart';

/// Common preview viewport presets.
enum HippoUiPreviewViewport {
  responsive(label: 'Responsive'),
  phoneCompact(label: 'Phone compact', size: Size(375, 667)),
  phoneRegular(label: 'Phone regular', size: Size(390, 844)),
  tabletPortrait(label: 'Tablet portrait', size: Size(820, 1180)),
  tabletLandscape(label: 'Tablet landscape', size: Size(1180, 820)),
  desktop(label: 'Desktop', size: Size(1440, 900));

  const HippoUiPreviewViewport({required this.label, this.size});

  final String label;

  final Size? size;

  bool get isResponsive => size == null;

  static HippoUiPreviewViewport? tryParse(String name) {
    return switch (name) {
      'responsive' => responsive,
      'phoneCompact' => phoneCompact,
      'phoneRegular' => phoneRegular,
      'tabletPortrait' => tabletPortrait,
      'tabletLandscape' => tabletLandscape,
      'desktop' => desktop,
      _ => null,
    };
  }
}

/// Flutter preview addon configuration for the preview viewport.
final class ViewportAddon extends HippoUiPreviewAddon<ViewportAddonState> {
  const ViewportAddon()
    : super(
        id: addonId,
        label: 'Viewport',
        configurationOptions: const [
          HippoUiEnumOption<HippoUiPreviewViewport>(
            key: 'viewport',
            label: 'Viewport',
            defaultValue: .responsive,
            values: [
              .new(value: .responsive, label: 'Responsive'),
              .new(value: .phoneCompact, label: 'Phone compact'),
              .new(value: .phoneRegular, label: 'Phone regular'),
              .new(value: .tabletPortrait, label: 'Tablet portrait'),
              .new(value: .tabletLandscape, label: 'Tablet landscape'),
              .new(value: .desktop, label: 'Desktop'),
            ],
          ),
        ],
      );

  static const addonId = 'viewport';

  @override
  ViewportAddonState get defaultState => const ViewportAddonState();

  @override
  ViewportAddonState decodeState(Object? json) => ViewportAddonState.fromJson(json);
}

/// Persisted state for [ViewportAddon].
final class ViewportAddonState extends HippoUiPreviewAddonState {
  const ViewportAddonState({this.viewport = HippoUiPreviewViewport.responsive})
    : super(addonId: ViewportAddon.addonId);

  final HippoUiPreviewViewport viewport;

  factory ViewportAddonState.fromJson(Object? json) {
    final configuration = HippoUiPreviewAddonState.readConfiguration(json);
    return ViewportAddonState(
      viewport:
          HippoUiPreviewViewport.tryParse(configuration['viewport'] as String? ?? '') ??
          HippoUiPreviewViewport.responsive,
    );
  }

  ViewportAddonState copyWith({HippoUiPreviewViewport? viewport}) {
    return ViewportAddonState(viewport: viewport ?? this.viewport);
  }

  @override
  Map<String, Object?> toJson() {
    return {'viewport': viewport.name};
  }
}

/// Applies the selected preview viewport to [child].
final class HippoUiPreviewViewportBuilder extends StatelessWidget {
  const HippoUiPreviewViewportBuilder({
    required this.state,
    required this.child,
    this.borderColor = const Color(0x66000000),
    this.borderWidth = 1,
    super.key,
  });

  final ViewportAddonState state;

  final Color borderColor;

  final double borderWidth;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = state.viewport.size;
    if (size == null) {
      return child;
    }

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(size: size),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: SizedBox.fromSize(size: size, child: child),
      ),
    );
  }
}
