/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

/// Const-friendly selectable value used by options with discrete choices.
class HippoUiOptionValue<T extends Object> {
  const HippoUiOptionValue({required this.value, this.label, this.description});

  /// Const primitive value used by generated preview wiring.
  final T value;

  /// Human-readable label. Defaults to [value].toString() in tooling.
  final String? label;

  final String? description;
}
