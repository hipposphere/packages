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

final class HippoUiCurveConverter extends HippoUiOptionConverter<Curve> {
  const HippoUiCurveConverter();

  static String encode(Curve curve) {
    if (curve == Curves.ease) {
      return 'ease';
    }
    if (curve == Curves.easeIn) {
      return 'easeIn';
    }
    if (curve == Curves.easeOut) {
      return 'easeOut';
    }
    if (curve == Curves.easeInOut) {
      return 'easeInOut';
    }
    if (curve == Curves.fastOutSlowIn) {
      return 'fastOutSlowIn';
    }
    if (curve == Curves.decelerate) {
      return 'decelerate';
    }
    if (curve == Curves.bounceOut) {
      return 'bounceOut';
    }
    if (curve == Curves.elasticOut) {
      return 'elasticOut';
    }
    return 'linear';
  }

  @override
  Curve convert(Object? value) {
    return switch (value) {
      'ease' => Curves.ease,
      'easeIn' => Curves.easeIn,
      'easeOut' => Curves.easeOut,
      'easeInOut' => Curves.easeInOut,
      'fastOutSlowIn' => Curves.fastOutSlowIn,
      'decelerate' => Curves.decelerate,
      'bounceOut' => Curves.bounceOut,
      'elasticOut' => Curves.elasticOut,
      _ => Curves.linear,
    };
  }
}
