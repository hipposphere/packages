/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:hippo_core/hippo_core.dart';
import 'package:test/test.dart';

void main() {
  test('represents an explicit nullable value change', () {
    const change = ValueChange<String?>(null);

    expect(change.value, isNull);
  });
}
