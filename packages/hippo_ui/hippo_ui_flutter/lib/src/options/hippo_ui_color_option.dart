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

import '../converters/hippo_ui_color_converter.dart';

final class HippoUiColorOption extends HippoUiOption {
  const HippoUiColorOption({
    this.key,
    this.label,
    this.description,
    this.defaultValue = const Color(0xff000000),
    this.values = const <HippoUiOptionValue<Color>>[],
    this.converter = const HippoUiColorConverter(),
  });

  @override
  final String? key;

  @override
  final String? label;

  @override
  final String? description;

  @override
  final Color defaultValue;

  final List<HippoUiOptionValue<Color>> values;

  @override
  final HippoUiOptionConverter<Color> converter;
}
