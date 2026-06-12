/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

/// Maps a JSON-safe playground option value to a constructor parameter value.
abstract class HippoUiOptionConverter<T> {
  const HippoUiOptionConverter();

  T convert(Object? value);
}
