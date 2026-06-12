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

import '../converters/hippo_ui_edge_insets_converter.dart';

final class HippoUiEdgeInsetsOption extends HippoUiOption {
  const HippoUiEdgeInsetsOption({
    this.key,
    this.label,
    this.description,
    this.defaultValue = EdgeInsets.zero,
    this.values = const <HippoUiOptionValue<EdgeInsets>>[],
    this.converter = const HippoUiEdgeInsetsConverter(),
  });

  @override
  final String? key;

  @override
  final String? label;

  @override
  final String? description;

  @override
  final EdgeInsets defaultValue;

  final List<HippoUiOptionValue<EdgeInsets>> values;

  @override
  final HippoUiOptionConverter<EdgeInsets> converter;
}
