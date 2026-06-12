/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

/// Framework-neutral theme type for preview and catalog tooling.
enum ThemeType {
  /// Follow the host platform or preview app theme.
  system,

  /// Force a light theme.
  light,

  /// Force a dark theme.
  dark;

  /// Returns the theme type for [name], or `null` when unknown.
  static ThemeType? tryParse(String name) {
    return switch (name) {
      'system' => system,
      'light' => light,
      'dark' => dark,
      _ => null,
    };
  }
}
