/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'dart:convert';

import 'hippo_ui_preview_addon.dart';
import 'hippo_ui_preview_session.dart';

/// Encodes preview sessions into URL-safe strings for deep links.
final class HippoUiPreviewSessionUrlCodec {
  const HippoUiPreviewSessionUrlCodec._();

  static String encode(HippoUiPreviewSession session) {
    final bytes = utf8.encode(jsonEncode(session.toJson()));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static HippoUiPreviewSession decode(
    String value, {
    Iterable<HippoUiPreviewAddon<HippoUiPreviewAddonState>> addons =
        const <HippoUiPreviewAddon<HippoUiPreviewAddonState>>[],
  }) {
    final normalizedValue = _restorePadding(value.trim());
    final jsonText = utf8.decode(base64Url.decode(normalizedValue));
    return HippoUiPreviewSession.fromJson(jsonDecode(jsonText), addons: addons);
  }

  static HippoUiPreviewSession? tryDecode(
    String value, {
    Iterable<HippoUiPreviewAddon<HippoUiPreviewAddonState>> addons =
        const <HippoUiPreviewAddon<HippoUiPreviewAddonState>>[],
  }) {
    try {
      return decode(value, addons: addons);
    } on FormatException {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  static String _restorePadding(String value) {
    final padding = value.length % 4;
    if (padding == 0) {
      return value;
    }
    return value.padRight(value.length + 4 - padding, '=');
  }
}
