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
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_ui/hippo_ui.dart';

import 'hippo_ui_playground_configuration.dart';

/// Runtime configuration state for a generated preview playground.
final class HippoUiPlaygroundState implements JsonEncodable {
  HippoUiPlaygroundState({required this.previewDefinition, required this.configuration});

  factory HippoUiPlaygroundState.fromPreviewDefinition(
    HippoUiGeneratedPreview previewDefinition, {
    Map<String, Object?> initialConfiguration = const <String, Object?>{},
  }) {
    return HippoUiPlaygroundState(
      previewDefinition: previewDefinition,
      configuration: DataSubject<HippoUiPlaygroundConfiguration>.seeded(
        HippoUiPlaygroundConfiguration.fromPreviewDefinition(
          previewDefinition,
          initialValues: initialConfiguration,
        ),
      ),
    );
  }

  final HippoUiGeneratedPreview previewDefinition;

  final DataSubject<HippoUiPlaygroundConfiguration> configuration;

  HippoUiPlaygroundConfiguration get currentConfiguration => configuration.value;

  Object? valueFor(String optionKey) {
    return currentConfiguration.valueFor(optionKey);
  }

  void updateConfiguration(HippoUiPlaygroundConfiguration value) {
    configuration.add(value);
  }

  void updateConfigurationValue(String optionKey, Object? value) {
    configuration.add(currentConfiguration.withValue(optionKey, value));
  }

  void clearConfigurationValue(String optionKey) {
    configuration.add(currentConfiguration.withoutValue(optionKey));
  }

  void resetConfiguration() {
    configuration.add(HippoUiPlaygroundConfiguration.fromPreviewDefinition(previewDefinition));
  }

  void dispose() {
    configuration.close();
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'preview': <String, Object?>{
        'id': previewDefinition.id,
        'targetName': previewDefinition.targetName,
        'name': previewDefinition.name,
        'path': previewDefinition.path,
      },
      'configuration': currentConfiguration.toJson(),
    };
  }
}
