/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:async';

import 'package:hippo_core/hippo_core.dart';
import 'package:test/test.dart';

void main() {
  test('can defer initialization until ready is accessed', () async {
    final store = _ControlledKeyValueStore()..storedString = '41';
    final controller = _createController(store, initializeOnCreation: false);

    await Future<void>.delayed(Duration.zero);
    expect(store.readCount, 0);
    expect(controller.subject.value, isNull);

    await controller.ready;

    expect(store.readCount, 1);
    expect(controller.currentValue, 41);
    await controller.initialize();
    expect(store.readCount, 1);
  });

  test('uses the default value when storage is empty', () async {
    final controller = _createController(_ControlledKeyValueStore());

    await controller.ready;

    expect(controller.currentValue, 7);
  });

  test('does not let a late initialization replace a newer update', () async {
    final read = Completer<String?>();
    final store = _ControlledKeyValueStore(read: () => read.future);
    final controller = _createController(store);

    final update = controller.update(12);
    read.complete('3');
    await Future.wait([controller.ready, update]);

    expect(controller.currentValue, 12);
    expect(store.storedString, '12');
  });

  test('persists concurrent updates in invocation order', () async {
    final firstWrite = Completer<void>();
    final store = _ControlledKeyValueStore(
      write: (index, _) => index == 0 ? firstWrite.future : Future<void>.value(),
    );
    final controller = _createController(store, initializeOnCreation: false);

    final first = controller.update(1);
    final second = controller.update(2);
    await Future<void>.delayed(Duration.zero);

    expect(controller.currentValue, 2);
    expect(store.writeValues, ['1']);

    firstWrite.complete();
    await Future.wait([first, second]);

    expect(store.writeValues, ['1', '2']);
    expect(store.storedString, '2');
  });

  test('continues the write queue after a failed write', () async {
    final store = _ControlledKeyValueStore(
      write: (index, _) async {
        if (index == 0) throw StateError('write failed');
      },
    );
    final controller = _createController(store, initializeOnCreation: false);

    await expectLater(controller.update(1), throwsStateError);
    await controller.update(2);

    expect(store.writeValues, ['1', '2']);
    expect(store.storedString, '2');
  });

  test('reports initialization errors through ready and the subject', () async {
    final error = StateError('read failed');
    final store = _ControlledKeyValueStore(read: () => Future<String?>.error(error));
    final controller = _createController(store, initializeOnCreation: false);
    final subjectError = controller.subject.stream.firstWhere((_) => false);

    await expectLater(controller.ready, throwsA(same(error)));
    await expectLater(subjectError, throwsA(same(error)));
  });

  test('ignores a pending initialization after disposal and rejects new work', () async {
    final read = Completer<String?>();
    final controller = _createController(_ControlledKeyValueStore(read: () => read.future));
    final ready = controller.ready;

    controller.dispose();
    controller.dispose();
    read.complete('9');
    await ready;

    expect(controller.subject.isClosed, isTrue);
    expect(() => controller.update(10), throwsStateError);
    expect(() => controller.initialize(), throwsStateError);
  });
}

StoreController<int> _createController(KeyValueStore store, {bool initializeOnCreation = true}) {
  return StoreController<int>(
    keyValueStore: store,
    storeKey: 'value',
    defaultValue: 7,
    itemDecoder: (data) => data as int,
    itemEncoder: (value) => value,
    initializeOnCreation: initializeOnCreation,
  );
}

final class _ControlledKeyValueStore implements KeyValueStore {
  _ControlledKeyValueStore({this.read, this.write});

  final Future<String?> Function()? read;
  final Future<void> Function(int index, String value)? write;
  String? storedString;
  int readCount = 0;
  final List<String> writeValues = <String>[];

  @override
  Future<bool> containsKey(String key) async => storedString != null;

  @override
  Future<bool?> getBool(String key) async => null;

  @override
  Future<double?> getDouble(String key) async => null;

  @override
  Future<int?> getInt(String key) async => null;

  @override
  Future<String?> getString(String key) {
    readCount += 1;
    return read?.call() ?? Future<String?>.value(storedString);
  }

  @override
  Future<void> removeValue(String key) async {
    storedString = null;
  }

  @override
  Future<void> setBool(String key, bool value) async {}

  @override
  Future<void> setDouble(String key, double value) async {}

  @override
  Future<void> setInt(String key, int value) async {}

  @override
  Future<void> setString(String key, String value) async {
    final index = writeValues.length;
    writeValues.add(value);
    await write?.call(index, value);
    storedString = value;
  }
}
