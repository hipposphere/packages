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
import 'package:hippo_ui/hippo_ui.dart';

import 'hippo_ui_playground_configuration.dart';
import 'hippo_ui_preview_addon.dart';
import 'hippo_ui_preview_environment_state.dart';

/// Serializable preview session for deep links and persisted playground state.
final class HippoUiPreviewSession implements JsonEncodable {
  const HippoUiPreviewSession({
    required this.previewId,
    this.version = currentVersion,
    this.configuration = const HippoUiPlaygroundConfiguration(),
    this.environment = HippoUiPreviewEnvironmentState.empty,
  });

  factory HippoUiPreviewSession.fromJson(
    Object? json, {
    Iterable<HippoUiPreviewAddon<HippoUiPreviewAddonState>> addons =
        const <HippoUiPreviewAddon<HippoUiPreviewAddonState>>[],
  }) {
    if (json is! Map) {
      return const HippoUiPreviewSession(previewId: '');
    }

    final previewId = json['previewId'];
    final legacyPreview = json['preview'];
    final legacyPreviewId = legacyPreview is Map ? legacyPreview['id'] : legacyPreview;

    return HippoUiPreviewSession(
      version: json['version'] is int ? json['version'] as int : currentVersion,
      previewId: previewId is String
          ? previewId
          : legacyPreviewId is String
          ? legacyPreviewId
          : '',
      configuration: HippoUiPlaygroundConfiguration.fromJson(json['configuration']),
      environment: HippoUiPreviewEnvironmentState.fromJson(json['environment'], addons: addons),
    );
  }

  factory HippoUiPreviewSession.fromPreview({
    required HippoUiGeneratedPreview preview,
    HippoUiPlaygroundConfiguration? configuration,
    HippoUiPreviewEnvironmentState environment = HippoUiPreviewEnvironmentState.empty,
  }) {
    return HippoUiPreviewSession(
      previewId: preview.id,
      configuration: configuration ?? HippoUiPlaygroundConfiguration.fromPreviewDefinition(preview),
      environment: environment,
    );
  }

  static const currentVersion = 1;

  final int version;

  final String previewId;

  final HippoUiPlaygroundConfiguration configuration;

  final HippoUiPreviewEnvironmentState environment;

  HippoUiGeneratedPreview? resolvePreview(HippoUiCatalog catalog) {
    return catalog.previewById(previewId);
  }

  HippoUiPreviewSession copyWith({
    int? version,
    String? previewId,
    HippoUiPlaygroundConfiguration? configuration,
    HippoUiPreviewEnvironmentState? environment,
  }) {
    return HippoUiPreviewSession(
      version: version ?? this.version,
      previewId: previewId ?? this.previewId,
      configuration: configuration ?? this.configuration,
      environment: environment ?? this.environment,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': version,
      'previewId': previewId,
      'configuration': configuration.toJson(),
      'environment': environment.toJson(),
    };
  }
}
