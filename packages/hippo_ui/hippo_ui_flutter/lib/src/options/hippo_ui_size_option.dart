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

import '../converters/hippo_ui_size_converter.dart';

final class HippoUiSizeOption extends HippoUiOption {
  const HippoUiSizeOption({
    this.key,
    this.label,
    this.description,
    this.defaultValue = Size.zero,
    this.values = const <HippoUiOptionValue<Size>>[],
    this.converter = const HippoUiSizeConverter(),
  });

  @override
  final String? key;

  @override
  final String? label;

  @override
  final String? description;

  @override
  final Size defaultValue;

  final List<HippoUiOptionValue<Size>> values;

  @override
  final HippoUiOptionConverter<Size> converter;
}
