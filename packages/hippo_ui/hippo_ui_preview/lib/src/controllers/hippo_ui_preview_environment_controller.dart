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

import '../models/hippo_ui_preview_addon.dart';
import '../models/hippo_ui_preview_environment_state.dart';
import '../models/hippo_ui_preview_session.dart';

/// Stores and exposes global preview environment state.
final class HippoUiPreviewEnvironmentController {
  HippoUiPreviewEnvironmentController({
    required KeyValueStore keyValueStore,
    String storeKey = defaultStoreKey,
    HippoUiPreviewEnvironmentState defaultState = HippoUiPreviewEnvironmentState.empty,
    HippoUiPreviewEnvironmentState? initialState,
    Iterable<HippoUiPreviewAddon<HippoUiPreviewAddonState>> addons =
        const <HippoUiPreviewAddon<HippoUiPreviewAddonState>>[],
  }) : environmentStateController = StoreController<HippoUiPreviewEnvironmentState>(
         keyValueStore: keyValueStore,
         storeKey: storeKey,
         defaultValue: defaultState,
         itemDecoder: (json) => HippoUiPreviewEnvironmentState.fromJson(json, addons: addons),
         itemEncoder: (state) => state.toJson(),
         initialValue: initialState ?? defaultState,
       ),
       super();

  static const defaultStoreKey = 'hippo_ui_preview_environment_state';

  final StoreController<HippoUiPreviewEnvironmentState> environmentStateController;

  DataSubject<HippoUiPreviewEnvironmentState?> get environmentState =>
      environmentStateController.subject;

  HippoUiPreviewEnvironmentState get currentEnvironmentState =>
      environmentStateController.currentValue;

  Future<void> updateEnvironmentState(HippoUiPreviewEnvironmentState state) async {
    await environmentStateController.update(state);
  }

  HippoUiPreviewSession applyCurrentEnvironment(HippoUiPreviewSession session) {
    return session.copyWith(environment: currentEnvironmentState);
  }

  Future<void> restoreSessionEnvironment(HippoUiPreviewSession session) async {
    await updateEnvironmentState(session.environment);
  }

  Future<void> updateAddonState(HippoUiPreviewAddonState addonState) async {
    await environmentStateController.updateBuilder(
      builder: (state) => state.copyWith(
        addonStates: <String, HippoUiPreviewAddonState>{
          ...state.addonStates,
          addonState.addonId: addonState,
        },
      ),
    );
  }

  Future<void> removeAddonState(String addonId) async {
    await environmentStateController.updateBuilder(
      builder: (state) {
        final addonStates = <String, HippoUiPreviewAddonState>{...state.addonStates}
          ..remove(addonId);
        return state.copyWith(addonStates: addonStates);
      },
    );
  }

  void dispose() {
    environmentStateController.dispose();
  }
}
