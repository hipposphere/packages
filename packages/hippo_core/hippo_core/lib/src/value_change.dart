/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

/// An explicit value update, including an explicit `null` value.
///
/// This is useful for APIs such as `copyWith`, where `null` means "set the
/// value to null" and a nullable argument means "leave the value unchanged".
final class ValueChange<T> {
  const ValueChange(this.value);

  final T value;
}
