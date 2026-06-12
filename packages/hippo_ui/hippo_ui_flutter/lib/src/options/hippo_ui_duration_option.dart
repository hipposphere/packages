/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:hippo_ui/hippo_ui.dart';

import '../converters/hippo_ui_duration_converter.dart';

final class HippoUiDurationOption extends HippoUiOption {
  const HippoUiDurationOption({
    this.key,
    this.label,
    this.description,
    this.defaultValue = Duration.zero,
    this.min,
    this.max,
    this.step,
    this.values = const <HippoUiOptionValue<Duration>>[],
    this.converter = const HippoUiDurationConverter(),
  });

  @override
  final String? key;

  @override
  final String? label;

  @override
  final String? description;

  @override
  final Duration defaultValue;

  final Duration? min;

  final Duration? max;

  final Duration? step;

  final List<HippoUiOptionValue<Duration>> values;

  @override
  final HippoUiOptionConverter<Duration> converter;
}
