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

final class HippoUiMainAxisAlignmentConverter extends HippoUiOptionConverter<MainAxisAlignment> {
  const HippoUiMainAxisAlignmentConverter();

  @override
  MainAxisAlignment convert(Object? value) {
    return switch (value) {
      'start' => .start,
      'end' => .end,
      'center' => .center,
      'spaceBetween' => .spaceBetween,
      'spaceAround' => .spaceAround,
      'spaceEvenly' => .spaceEvenly,
      _ => .start,
    };
  }
}
