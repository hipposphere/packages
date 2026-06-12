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

final class HippoUiEdgeInsetsConverter extends HippoUiOptionConverter<EdgeInsets> {
  const HippoUiEdgeInsetsConverter();

  static Map<String, Object?> encode(EdgeInsets edgeInsets) {
    return <String, Object?>{
      'left': edgeInsets.left,
      'top': edgeInsets.top,
      'right': edgeInsets.right,
      'bottom': edgeInsets.bottom,
    };
  }

  @override
  EdgeInsets convert(Object? value) {
    if (value is Map) {
      return EdgeInsets.fromLTRB(
        _double(value['left']),
        _double(value['top']),
        _double(value['right']),
        _double(value['bottom']),
      );
    }
    return EdgeInsets.zero;
  }

  double _double(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return 0;
  }
}
