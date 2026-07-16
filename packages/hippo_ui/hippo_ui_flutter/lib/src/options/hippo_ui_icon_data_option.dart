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

final class HippoUiIconDataOption extends HippoUiOption {
  const HippoUiIconDataOption({
    this.key,
    this.label,
    this.description,
    this.defaultValue = const IconData(0),
    this.values = const <HippoUiOptionValue<IconData>>[],
  });

  @override
  final String? key;

  @override
  final String? label;

  @override
  final String? description;

  @override
  final IconData defaultValue;

  final List<HippoUiOptionValue<IconData>> values;

  @override
  HippoUiOptionConverter<dynamic>? get converter => null;
}
