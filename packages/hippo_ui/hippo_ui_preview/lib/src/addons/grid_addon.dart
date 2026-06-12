/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import '../models/hippo_ui_preview_addon.dart';

/// Preview addon configuration for a grid overlay.
final class GridAddon extends HippoUiPreviewAddon<GridAddonState> {
  const GridAddon()
    : super(
        id: addonId,
        label: 'Grid',
        configurationOptions: const [
          .boolean(key: 'enabled', label: 'Enabled', defaultValue: false),
          .doubleRange(key: 'size', label: 'Size', defaultValue: 8, min: 2, max: 64, step: 1),
        ],
      );

  static const addonId = 'grid';

  @override
  GridAddonState get defaultState => const GridAddonState();

  @override
  GridAddonState decodeState(Object? json) => GridAddonState.fromJson(json);
}

/// Persisted state for [GridAddon].
final class GridAddonState extends HippoUiPreviewAddonState {
  const GridAddonState({this.enabled = false, this.size = 8}) : super(addonId: GridAddon.addonId);

  final bool enabled;

  final double size;

  factory GridAddonState.fromJson(Object? json) {
    final configuration = HippoUiPreviewAddonState.readConfiguration(json);
    return GridAddonState(
      enabled: configuration['enabled'] as bool? ?? false,
      size: readHippoUiPreviewDouble(configuration['size']) ?? 8,
    );
  }

  GridAddonState copyWith({bool? enabled, double? size}) {
    return GridAddonState(enabled: enabled ?? this.enabled, size: size ?? this.size);
  }

  @override
  Map<String, Object?> toJson() {
    return {'enabled': enabled, 'size': size};
  }
}
