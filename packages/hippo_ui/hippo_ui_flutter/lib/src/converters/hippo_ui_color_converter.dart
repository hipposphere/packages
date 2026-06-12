/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:flutter/widgets.dart';
import 'package:hippo_ui/hippo_ui.dart';

final class HippoUiColorConverter extends HippoUiOptionConverter<Color> {
  const HippoUiColorConverter();

  static int encode(Color color) {
    return color.toARGB32();
  }

  @override
  Color convert(Object? value) {
    if (value is int) {
      // Color is reconstructed from JSON-safe generated preview metadata.
      return Color(
        // ignore: non_const_argument_for_const_parameter
        value,
      );
    }
    if (value is String) {
      final normalized = value.replaceFirst('#', '');
      final parsed = int.tryParse(normalized, radix: 16);
      if (parsed != null) {
        return Color(
          // ignore: non_const_argument_for_const_parameter
          normalized.length == 6 ? 0xff000000 | parsed : parsed,
        );
      }
    }
    return const Color(0xff000000);
  }
}
