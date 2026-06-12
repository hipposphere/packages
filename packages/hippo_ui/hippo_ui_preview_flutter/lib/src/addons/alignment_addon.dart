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

/// Flutter preview addon configuration for preview canvas alignment.
final class AlignmentAddon extends HippoUiPreviewAddon<AlignmentAddonState> {
  const AlignmentAddon()
    : super(
        id: addonId,
        label: 'Alignment',
        configurationOptions: const [
          HippoUiAlignmentOption(key: 'alignment', label: 'Alignment', defaultValue: .center),
        ],
      );

  static const addonId = 'alignment';

  @override
  AlignmentAddonState get defaultState => const AlignmentAddonState();

  @override
  AlignmentAddonState decodeState(Object? json) => AlignmentAddonState.fromJson(json);
}

/// Persisted state for [AlignmentAddon].
final class AlignmentAddonState extends HippoUiPreviewAddonState {
  const AlignmentAddonState({this.alignment = Alignment.center})
    : super(addonId: AlignmentAddon.addonId);

  final Alignment alignment;

  factory AlignmentAddonState.fromJson(Object? json) {
    final configuration = HippoUiPreviewAddonState.readConfiguration(json);
    return AlignmentAddonState(
      alignment: const HippoUiAlignmentConverter().convert(configuration['alignment']),
    );
  }

  AlignmentAddonState copyWith({Alignment? alignment}) {
    return AlignmentAddonState(alignment: alignment ?? this.alignment);
  }

  @override
  Map<String, Object?> toJson() {
    return {'alignment': HippoUiAlignmentConverter.encode(alignment)};
  }
}
