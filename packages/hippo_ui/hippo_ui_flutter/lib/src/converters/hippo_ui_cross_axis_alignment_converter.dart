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

final class HippoUiCrossAxisAlignmentConverter extends HippoUiOptionConverter<CrossAxisAlignment> {
  const HippoUiCrossAxisAlignmentConverter();

  @override
  CrossAxisAlignment convert(Object? value) {
    return switch (value) {
      'start' => .start,
      'end' => .end,
      'center' => .center,
      'stretch' => .stretch,
      'baseline' => .baseline,
      _ => .center,
    };
  }
}
