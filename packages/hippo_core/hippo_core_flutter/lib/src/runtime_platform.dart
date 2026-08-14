/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter/foundation.dart';
import 'package:hippo_core/hippo_core.dart';

/// The platform on which the current Flutter application is running.
RuntimePlatform get currentRuntimePlatform {
  if (kIsWeb) return RuntimePlatform.web;

  return switch (defaultTargetPlatform) {
    TargetPlatform.android => RuntimePlatform.android,
    TargetPlatform.iOS => RuntimePlatform.iOS,
    TargetPlatform.macOS => RuntimePlatform.macOS,
    TargetPlatform.windows => RuntimePlatform.windows,
    TargetPlatform.linux => RuntimePlatform.linux,
    TargetPlatform.fuchsia => RuntimePlatform.fuchsia,
  };
}
