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

final class HippoUiTextAlignConverter extends HippoUiOptionConverter<TextAlign> {
  const HippoUiTextAlignConverter();

  @override
  TextAlign convert(Object? value) {
    return switch (value) {
      'left' => .left,
      'right' => .right,
      'center' => .center,
      'justify' => .justify,
      'start' => .start,
      'end' => .end,
      _ => .start,
    };
  }
}
