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

/// Preview addon configuration for preview canvas zoom.
final class ZoomAddon extends HippoUiPreviewAddon<ZoomAddonState> {
  const ZoomAddon()
    : super(
        id: addonId,
        label: 'Zoom',
        configurationOptions: const [
          .doubleRange(
            key: 'scale',
            label: 'Scale',
            defaultValue: 1,
            min: 0.25,
            max: 4,
            step: 0.05,
          ),
        ],
      );

  static const addonId = 'zoom';

  @override
  ZoomAddonState get defaultState => const ZoomAddonState();

  @override
  ZoomAddonState decodeState(Object? json) => ZoomAddonState.fromJson(json);
}

/// Persisted state for [ZoomAddon].
final class ZoomAddonState extends HippoUiPreviewAddonState {
  const ZoomAddonState({this.scale = 1}) : super(addonId: ZoomAddon.addonId);

  final double scale;

  factory ZoomAddonState.fromJson(Object? json) {
    final configuration = HippoUiPreviewAddonState.readConfiguration(json);
    return ZoomAddonState(scale: readHippoUiPreviewDouble(configuration['scale']) ?? 1);
  }

  ZoomAddonState copyWith({double? scale}) {
    return ZoomAddonState(scale: scale ?? this.scale);
  }

  @override
  Map<String, Object?> toJson() {
    return {'scale': scale};
  }
}
