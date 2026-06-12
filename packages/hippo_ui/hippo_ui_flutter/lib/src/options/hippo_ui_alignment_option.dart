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

import '../converters/hippo_ui_alignment_converter.dart';

final class HippoUiAlignmentOption extends HippoUiOption {
  const HippoUiAlignmentOption({
    this.key,
    this.label,
    this.description,
    this.defaultValue = .center,
    this.values = const [
      .new(value: .topLeft, label: 'Top left'),
      .new(value: .topCenter, label: 'Top center'),
      .new(value: .topRight, label: 'Top right'),
      .new(value: .centerLeft, label: 'Center left'),
      .new(value: .center, label: 'Center'),
      .new(value: .centerRight, label: 'Center right'),
      .new(value: .bottomLeft, label: 'Bottom left'),
      .new(value: .bottomCenter, label: 'Bottom center'),
      .new(value: .bottomRight, label: 'Bottom right'),
    ],
    this.converter = const HippoUiAlignmentConverter(),
  });

  @override
  final String? key;

  @override
  final String? label;

  @override
  final String? description;

  @override
  final Alignment defaultValue;

  final List<HippoUiOptionValue<Alignment>> values;

  @override
  final HippoUiOptionConverter<Alignment> converter;
}
