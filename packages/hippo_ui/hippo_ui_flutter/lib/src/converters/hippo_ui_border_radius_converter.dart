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

final class HippoUiBorderRadiusConverter extends HippoUiOptionConverter<BorderRadius> {
  const HippoUiBorderRadiusConverter();

  static Map<String, Object?> encode(BorderRadius borderRadius) {
    return <String, Object?>{
      'topLeft': _encodeRadius(borderRadius.topLeft),
      'topRight': _encodeRadius(borderRadius.topRight),
      'bottomLeft': _encodeRadius(borderRadius.bottomLeft),
      'bottomRight': _encodeRadius(borderRadius.bottomRight),
    };
  }

  @override
  BorderRadius convert(Object? value) {
    if (value is Map) {
      return BorderRadius.only(
        topLeft: _radius(value['topLeft']),
        topRight: _radius(value['topRight']),
        bottomLeft: _radius(value['bottomLeft']),
        bottomRight: _radius(value['bottomRight']),
      );
    }
    return BorderRadius.zero;
  }

  static Map<String, Object?> _encodeRadius(Radius radius) {
    return <String, Object?>{'x': radius.x, 'y': radius.y};
  }

  Radius _radius(Object? value) {
    if (value is Map) {
      return Radius.elliptical(_double(value['x']), _double(value['y']));
    }
    return Radius.zero;
  }

  double _double(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return 0;
  }
}
