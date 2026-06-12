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

final class HippoUiAlignmentConverter extends HippoUiOptionConverter<Alignment> {
  const HippoUiAlignmentConverter();

  static String encode(Alignment alignment) {
    if (alignment == Alignment.topLeft) {
      return 'topLeft';
    }
    if (alignment == Alignment.topCenter) {
      return 'topCenter';
    }
    if (alignment == Alignment.topRight) {
      return 'topRight';
    }
    if (alignment == Alignment.centerLeft) {
      return 'centerLeft';
    }
    if (alignment == Alignment.centerRight) {
      return 'centerRight';
    }
    if (alignment == Alignment.bottomLeft) {
      return 'bottomLeft';
    }
    if (alignment == Alignment.bottomCenter) {
      return 'bottomCenter';
    }
    if (alignment == Alignment.bottomRight) {
      return 'bottomRight';
    }
    return 'center';
  }

  @override
  Alignment convert(Object? value) {
    return switch (value) {
      'topLeft' => .topLeft,
      'topCenter' => .topCenter,
      'topRight' => .topRight,
      'centerLeft' => .centerLeft,
      'center' => .center,
      'centerRight' => .centerRight,
      'bottomLeft' => .bottomLeft,
      'bottomCenter' => .bottomCenter,
      'bottomRight' => .bottomRight,
      _ => .center,
    };
  }
}
