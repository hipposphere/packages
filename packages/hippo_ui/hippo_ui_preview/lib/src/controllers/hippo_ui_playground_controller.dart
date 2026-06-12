/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_ui/hippo_ui.dart';

import '../models/hippo_ui_playground_configuration.dart';
import '../models/hippo_ui_playground_state.dart';
import '../models/hippo_ui_preview_environment_state.dart';
import '../models/hippo_ui_preview_session.dart';

/// Holds mutable playground configuration for the active preview definition.
final class HippoUiPlaygroundController {
  HippoUiPlaygroundController({
    required HippoUiGeneratedPreview previewDefinition,
    Map<String, Object?> initialConfiguration = const <String, Object?>{},
  }) : playgroundState = DataSubject<HippoUiPlaygroundState>.seeded(
         HippoUiPlaygroundState.fromPreviewDefinition(
           previewDefinition,
           initialConfiguration: initialConfiguration,
         ),
       ),
       super();

  final DataSubject<HippoUiPlaygroundState> playgroundState;

  HippoUiPlaygroundState get currentPlaygroundState => playgroundState.value;

  void loadPreviewDefinition(
    HippoUiGeneratedPreview previewDefinition, {
    Map<String, Object?> configuration = const <String, Object?>{},
  }) {
    currentPlaygroundState.dispose();
    playgroundState.add(
      HippoUiPlaygroundState.fromPreviewDefinition(
        previewDefinition,
        initialConfiguration: configuration,
      ),
    );
  }

  void updateConfigurationValue(String optionKey, Object? value) {
    currentPlaygroundState.updateConfigurationValue(optionKey, value);
  }

  void updateConfiguration(HippoUiPlaygroundConfiguration configuration) {
    currentPlaygroundState.updateConfiguration(configuration);
  }

  HippoUiPreviewSession createSession({
    HippoUiPreviewEnvironmentState environment = HippoUiPreviewEnvironmentState.empty,
  }) {
    return HippoUiPreviewSession.fromPreview(
      preview: currentPlaygroundState.previewDefinition,
      configuration: currentPlaygroundState.currentConfiguration,
      environment: environment,
    );
  }

  bool loadSession(HippoUiPreviewSession session, HippoUiCatalog catalog) {
    final previewDefinition = session.resolvePreview(catalog);
    if (previewDefinition == null) {
      return false;
    }

    loadPreviewDefinition(previewDefinition, configuration: session.configuration.values);
    return true;
  }

  void clearConfigurationValue(String optionKey) {
    currentPlaygroundState.clearConfigurationValue(optionKey);
  }

  void resetConfiguration() {
    currentPlaygroundState.resetConfiguration();
  }

  void dispose() {
    currentPlaygroundState.dispose();
    playgroundState.close();
  }
}
