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

import '../converters/hippo_ui_box_constraints_converter.dart';

final class HippoUiBoxConstraintsOption extends HippoUiOption {
  const HippoUiBoxConstraintsOption({
    this.key,
    this.label,
    this.description,
    this.defaultValue = const BoxConstraints(),
    this.values = const <HippoUiOptionValue<BoxConstraints>>[],
    this.converter = const HippoUiBoxConstraintsConverter(),
  });

  @override
  final String? key;

  @override
  final String? label;

  @override
  final String? description;

  @override
  final BoxConstraints defaultValue;

  final List<HippoUiOptionValue<BoxConstraints>> values;

  @override
  final HippoUiOptionConverter<BoxConstraints> converter;
}
