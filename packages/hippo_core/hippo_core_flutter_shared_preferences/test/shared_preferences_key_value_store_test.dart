/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_core_flutter_shared_preferences/hippo_core_flutter_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  test('stores supported values with the configured prefix', () async {
    final platform = InMemorySharedPreferencesAsync.empty();
    SharedPreferencesAsyncPlatform.instance = platform;
    final preferences = SharedPreferencesAsync();
    final store = SharedPreferencesKeyValueStore(
      storePrefix: 'test',
      sharedPreferencesAsync: preferences,
    );

    await store.setString('name', 'Hippo');
    await store.setBool('enabled', true);
    await store.setInt('count', 3);
    await store.setDouble('ratio', 1.5);

    expect(await store.getString('name'), 'Hippo');
    expect(await store.getBool('enabled'), isTrue);
    expect(await store.getInt('count'), 3);
    expect(await store.getDouble('ratio'), 1.5);
    expect(await store.containsKey('name'), isTrue);
    expect(await preferences.getString('test.name'), 'Hippo');

    await store.removeValue('name');

    expect(await store.containsKey('name'), isFalse);
  });
}
