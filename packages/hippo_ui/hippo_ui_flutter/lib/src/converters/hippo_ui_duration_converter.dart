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

final class HippoUiDurationConverter extends HippoUiOptionConverter<Duration> {
  const HippoUiDurationConverter();

  static int encode(Duration duration) {
    return duration.inMilliseconds;
  }

  @override
  Duration convert(Object? value) {
    if (value is int) {
      return Duration(milliseconds: value);
    }
    return Duration.zero;
  }
}
