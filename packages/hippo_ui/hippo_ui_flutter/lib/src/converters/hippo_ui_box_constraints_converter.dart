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

final class HippoUiBoxConstraintsConverter extends HippoUiOptionConverter<BoxConstraints> {
  const HippoUiBoxConstraintsConverter();

  static Map<String, Object?> encode(BoxConstraints constraints) {
    final encoded = <String, Object?>{
      'minWidth': constraints.minWidth,
      'minHeight': constraints.minHeight,
    };
    if (constraints.maxWidth.isFinite) {
      encoded['maxWidth'] = constraints.maxWidth;
    }
    if (constraints.maxHeight.isFinite) {
      encoded['maxHeight'] = constraints.maxHeight;
    }
    return encoded;
  }

  @override
  BoxConstraints convert(Object? value) {
    if (value is Map) {
      return BoxConstraints(
        minWidth: _double(value['minWidth']),
        maxWidth: _double(value['maxWidth'], double.infinity),
        minHeight: _double(value['minHeight']),
        maxHeight: _double(value['maxHeight'], double.infinity),
      );
    }
    return const BoxConstraints();
  }

  double _double(Object? value, [double fallback = 0]) {
    if (value is num) {
      return value.toDouble();
    }
    return fallback;
  }
}
