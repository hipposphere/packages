/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

/// The platform on which an application is currently running.
enum RuntimePlatform { web, android, iOS, macOS, windows, linux, fuchsia }

/// Common platform categories for [RuntimePlatform].
extension RuntimePlatformX on RuntimePlatform {
  /// Whether the application runs in a web browser.
  bool get isWeb => this == RuntimePlatform.web;

  /// Whether the application runs outside a web browser.
  bool get isNative => !isWeb;

  /// Whether the application runs as a native desktop application.
  bool get isDesktop => switch (this) {
    RuntimePlatform.macOS || RuntimePlatform.windows || RuntimePlatform.linux => true,
    _ => false,
  };

  /// Whether the application runs as a native mobile application.
  bool get isMobile => switch (this) {
    RuntimePlatform.android || RuntimePlatform.iOS => true,
    _ => false,
  };
}
