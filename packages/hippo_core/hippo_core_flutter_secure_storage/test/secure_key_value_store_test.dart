/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_core_flutter_secure_storage/hippo_core_flutter_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  test('stores supported values with the configured prefix', () async {
    final store = SecureKeyValueStore(storePrefix: 'test');

    await store.setString('name', 'Hippo');
    await store.setBool('enabled', true);
    await store.setInt('count', 3);
    await store.setDouble('ratio', 1.5);

    expect(await store.getString('name'), 'Hippo');
    expect(await store.getBool('enabled'), isTrue);
    expect(await store.getInt('count'), 3);
    expect(await store.getDouble('ratio'), 1.5);
    expect(await store.containsKey('name'), isTrue);
    expect(await const FlutterSecureStorage().read(key: 'test.name'), 'Hippo');

    await store.removeValue('name');

    expect(await store.containsKey('name'), isFalse);
  });
}
