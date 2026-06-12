/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:hippo_ui/hippo_ui.dart';

import '../models/hippo_ui_preview_addon.dart';

/// Preview addon configuration for theme type selection.
final class ThemeTypeAddon extends HippoUiPreviewAddon<ThemeTypeAddonState> {
  const ThemeTypeAddon()
    : super(
        id: addonId,
        label: 'Theme type',
        configurationOptions: const [
          HippoUiEnumOption<ThemeType>(
            key: 'themeType',
            label: 'Theme type',
            defaultValue: .system,
            values: [
              .new(value: .system, label: 'System'),
              .new(value: .light, label: 'Light'),
              .new(value: .dark, label: 'Dark'),
            ],
          ),
        ],
      );

  static const addonId = 'themeType';

  @override
  ThemeTypeAddonState get defaultState => const ThemeTypeAddonState();

  @override
  ThemeTypeAddonState decodeState(Object? json) => ThemeTypeAddonState.fromJson(json);
}

/// Persisted state for [ThemeTypeAddon].
final class ThemeTypeAddonState extends HippoUiPreviewAddonState {
  const ThemeTypeAddonState({this.themeType = ThemeType.system})
    : super(addonId: ThemeTypeAddon.addonId);

  final ThemeType themeType;

  factory ThemeTypeAddonState.fromJson(Object? json) {
    final configuration = HippoUiPreviewAddonState.readConfiguration(json);
    return ThemeTypeAddonState(
      themeType:
          ThemeType.tryParse(configuration['themeType'] as String? ?? '') ?? ThemeType.system,
    );
  }

  ThemeTypeAddonState copyWith({ThemeType? themeType}) {
    return ThemeTypeAddonState(themeType: themeType ?? this.themeType);
  }

  @override
  Map<String, Object?> toJson() {
    return {'themeType': themeType.name};
  }
}
