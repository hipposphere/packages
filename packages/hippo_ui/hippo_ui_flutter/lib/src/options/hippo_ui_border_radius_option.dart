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

import '../converters/hippo_ui_border_radius_converter.dart';

final class HippoUiBorderRadiusOption extends HippoUiOption {
  const HippoUiBorderRadiusOption({
    this.key,
    this.label,
    this.description,
    this.defaultValue = BorderRadius.zero,
    this.values = const <HippoUiOptionValue<BorderRadius>>[],
    this.converter = const HippoUiBorderRadiusConverter(),
  });

  @override
  final String? key;

  @override
  final String? label;

  @override
  final String? description;

  @override
  final BorderRadius defaultValue;

  final List<HippoUiOptionValue<BorderRadius>> values;

  @override
  final HippoUiOptionConverter<BorderRadius> converter;
}
