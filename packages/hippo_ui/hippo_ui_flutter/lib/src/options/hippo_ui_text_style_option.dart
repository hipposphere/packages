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

final class HippoUiTextStyleOption<T extends TextStyle> extends HippoUiOption {
  const HippoUiTextStyleOption({
    this.key,
    this.label,
    this.description,
    this.defaultValue = '',
    this.values = const <HippoUiOptionValue<String>>[],
    required this.converter,
  });

  @override
  final String? key;

  @override
  final String? label;

  @override
  final String? description;

  @override
  final String defaultValue;

  final List<HippoUiOptionValue<String>> values;

  @override
  final HippoUiOptionConverter<T> converter;
}
