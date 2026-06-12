/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:dart_edge_core/dart_edge_core.dart';

import 'hippo_ui_preview_addon.dart';

/// Global preview environment state shared across rendered previews.
final class HippoUiPreviewEnvironmentState implements JsonEncodable {
  const HippoUiPreviewEnvironmentState({
    this.addonStates = const <String, HippoUiPreviewAddonState>{},
  });

  static const empty = HippoUiPreviewEnvironmentState();

  final Map<String, HippoUiPreviewAddonState> addonStates;

  factory HippoUiPreviewEnvironmentState.fromJson(
    Object? json, {
    Iterable<HippoUiPreviewAddon<HippoUiPreviewAddonState>> addons =
        const <HippoUiPreviewAddon<HippoUiPreviewAddonState>>[],
  }) {
    if (json is! Map) {
      return empty;
    }

    return HippoUiPreviewEnvironmentState(
      addonStates: _readAddonStates(json['addons'], addons: addons),
    );
  }

  HippoUiPreviewEnvironmentState copyWith({Map<String, HippoUiPreviewAddonState>? addonStates}) {
    return HippoUiPreviewEnvironmentState(addonStates: addonStates ?? this.addonStates);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'addons': addonStates.map((addonId, addonState) => MapEntry(addonId, addonState.toJson())),
    };
  }

  static Map<String, HippoUiPreviewAddonState> _readAddonStates(
    Object? json, {
    Iterable<HippoUiPreviewAddon<HippoUiPreviewAddonState>> addons =
        const <HippoUiPreviewAddon<HippoUiPreviewAddonState>>[],
  }) {
    final addonsById = <String, HippoUiPreviewAddon<HippoUiPreviewAddonState>>{
      for (final addon in addons) addon.id: addon,
    };

    if (json is Map) {
      return Map<String, HippoUiPreviewAddonState>.fromEntries(
        json.entries.where((entry) => entry.key is String).map((entry) {
          final addonId = entry.key as String;
          return MapEntry(
            addonId,
            addonsById[addonId]?.decodeState(entry.value) ??
                HippoUiPreviewAddonState.fromJson(addonId, entry.value),
          );
        }),
      );
    }

    if (json is List) {
      return Map<String, HippoUiPreviewAddonState>.fromEntries(
        json
            .whereType<Map>()
            .where((addon) => addon['name'] is String)
            .map(
              (addon) => MapEntry(
                addon['name'] as String,
                addonsById[addon['name']]?.decodeState(addon['configuration']) ??
                    HippoUiPreviewAddonState.fromJson(
                      addon['name'] as String,
                      addon['configuration'],
                    ),
              ),
            ),
      );
    }

    return const <String, HippoUiPreviewAddonState>{};
  }
}
