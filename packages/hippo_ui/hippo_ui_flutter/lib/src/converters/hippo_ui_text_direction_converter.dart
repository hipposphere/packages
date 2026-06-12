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

final class HippoUiTextDirectionConverter extends HippoUiOptionConverter<TextDirection> {
  const HippoUiTextDirectionConverter();

  @override
  TextDirection convert(Object? value) {
    return switch (value) {
      'ltr' => .ltr,
      'rtl' => .rtl,
      _ => .ltr,
    };
  }
}
