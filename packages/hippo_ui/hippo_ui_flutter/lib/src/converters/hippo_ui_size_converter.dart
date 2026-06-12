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

final class HippoUiSizeConverter extends HippoUiOptionConverter<Size> {
  const HippoUiSizeConverter();

  static Map<String, Object?> encode(Size size) {
    return <String, Object?>{'width': size.width, 'height': size.height};
  }

  @override
  Size convert(Object? value) {
    if (value is Map) {
      return Size(_double(value['width']), _double(value['height']));
    }
    return Size.zero;
  }

  double _double(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return 0;
  }
}
