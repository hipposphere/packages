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

/// Base type for preview addon definitions.
abstract class HippoUiPreviewAddon<TState extends HippoUiPreviewAddonState> {
  const HippoUiPreviewAddon({
    required this.id,
    this.label,
    this.description,
    this.configurationOptions = const <HippoUiOption>[],
  });

  final String id;

  final String? label;

  final String? description;

  final List<HippoUiOption> configurationOptions;

  TState get defaultState;

  TState decodeState(Object? json);
}

/// Base type for serializable preview addon state.
abstract class HippoUiPreviewAddonState {
  const HippoUiPreviewAddonState({required this.addonId});

  final String addonId;

  factory HippoUiPreviewAddonState.fromJson(String addonId, Object? json) {
    return HippoUiPreviewConfiguredAddonState.fromJson(addonId, json);
  }

  Map<String, Object?> toJson();

  static Map<String, Object?> readConfiguration(Object? json) {
    if (json is! Map) {
      return const <String, Object?>{};
    }

    return Map<String, Object?>.fromEntries(
      json.entries
          .where((entry) => entry.key is String)
          .map((entry) => MapEntry(entry.key as String, entry.value)),
    );
  }
}

double? readHippoUiPreviewDouble(Object? value) {
  return switch (value) {
    final double doubleValue => doubleValue,
    final int intValue => intValue.toDouble(),
    _ => null,
  };
}

/// Generic persisted addon state for unknown addon ids.
final class HippoUiPreviewConfiguredAddonState extends HippoUiPreviewAddonState {
  const HippoUiPreviewConfiguredAddonState({
    required super.addonId,
    this.configuration = const <String, Object?>{},
  });

  factory HippoUiPreviewConfiguredAddonState.fromJson(String addonId, Object? json) {
    return HippoUiPreviewConfiguredAddonState(
      addonId: addonId,
      configuration: HippoUiPreviewAddonState.readConfiguration(json),
    );
  }

  final Map<String, Object?> configuration;

  HippoUiPreviewConfiguredAddonState copyWith({
    String? addonId,
    Map<String, Object?>? configuration,
  }) {
    return HippoUiPreviewConfiguredAddonState(
      addonId: addonId ?? this.addonId,
      configuration: configuration ?? this.configuration,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return configuration;
  }
}
