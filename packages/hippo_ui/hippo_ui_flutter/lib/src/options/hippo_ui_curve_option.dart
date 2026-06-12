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

import '../converters/hippo_ui_curve_converter.dart';

final class HippoUiCurveOption extends HippoUiOption {
  const HippoUiCurveOption({
    this.key,
    this.label,
    this.description,
    this.defaultValue = Curves.linear,
    this.values = const <HippoUiOptionValue<Curve>>[
      HippoUiOptionValue<Curve>(value: Curves.linear, label: 'Linear'),
      HippoUiOptionValue<Curve>(value: Curves.ease, label: 'Ease'),
      HippoUiOptionValue<Curve>(value: Curves.easeIn, label: 'Ease in'),
      HippoUiOptionValue<Curve>(value: Curves.easeOut, label: 'Ease out'),
      HippoUiOptionValue<Curve>(value: Curves.easeInOut, label: 'Ease in out'),
      HippoUiOptionValue<Curve>(value: Curves.fastOutSlowIn, label: 'Fast out slow in'),
    ],
    this.converter = const HippoUiCurveConverter(),
  });

  @override
  final String? key;

  @override
  final String? label;

  @override
  final String? description;

  @override
  final Curve defaultValue;

  final List<HippoUiOptionValue<Curve>> values;

  @override
  final HippoUiOptionConverter<Curve> converter;
}
