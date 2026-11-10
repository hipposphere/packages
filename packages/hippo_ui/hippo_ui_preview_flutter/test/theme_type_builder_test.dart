/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_ui_preview_flutter/hippo_ui_preview_flutter.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('applies the selected Material theme to the preview', (tester) async {
    Brightness? brightness;
    await tester.pumpWidget(
      MaterialApp(
        home: HippoUiPreviewThemeTypeBuilder(
          state: const ThemeTypeAddonState(themeType: .dark),
          child: Builder(
            builder: (context) {
              brightness = Theme.of(context).brightness;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(brightness, Brightness.dark);
  });
}
