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
  test('evicts and disposes the least recently used resource', () {
    final disposed = <String>[];
    final cache = LruResourceCache<String, String>(
      capacity: 2,
      disposeResource: (key, value) => disposed.add('$key:$value'),
    );

    cache.getOrCreate('a', () => 'A');
    cache.getOrCreate('b', () => 'B');
    expect(cache.get('a'), 'A');
    cache.getOrCreate('c', () => 'C');

    expect(cache.keys, ['a', 'c']);
    expect(disposed, ['b:B']);
  });

  test('temporarily overflows when older resources cannot be evicted', () {
    final busyKeys = <String>{'a'};
    final disposed = <String>[];
    final cache = LruResourceCache<String, String>(
      capacity: 1,
      canEvict: (key, _) => !busyKeys.contains(key),
      disposeResource: (key, _) => disposed.add(key),
    );

    cache.getOrCreate('a', () => 'A');
    final inserted = cache.getOrCreate('b', () => 'B');

    expect(inserted, 'B');
    expect(cache.keys, ['a', 'b']);
    expect(cache.isOverCapacity, isTrue);
    expect(disposed, isEmpty);

    busyKeys.clear();
    expect(cache.trim(), 1);
    expect(cache.keys, ['b']);
    expect(disposed, ['a']);
  });

  test('pinned resources survive trimming until unpinned', () {
    final disposed = <String>[];
    final cache = LruResourceCache<String, String>(
      capacity: 1,
      disposeResource: (key, _) => disposed.add(key),
    );

    cache.getOrCreate('primary', () => 'Primary', pinned: true);
    cache.getOrCreate('secondary', () => 'Secondary');

    expect(cache.keys, ['primary', 'secondary']);
    expect(cache.isPinned('primary'), isTrue);

    expect(cache.unpin('primary'), isTrue);
    expect(cache.keys, ['secondary']);
    expect(disposed, ['primary']);
  });

  test('replacement, removal, clear, and dispose release owned resources', () {
    final disposed = <String>[];
    final cache = LruResourceCache<String, String>(
      capacity: 3,
      disposeResource: (key, value) => disposed.add('$key:$value'),
    );

    cache.put('a', 'A1');
    cache.put('a', 'A2');
    cache.put('b', 'B');
    expect(cache.remove('a', dispose: false), 'A2');
    cache.put('c', 'C');
    cache.clear();
    cache.put('d', 'D');
    cache.dispose();
    cache.dispose();

    expect(disposed, ['a:A1', 'b:B', 'c:C', 'd:D']);
    expect(() => cache.getOrCreate('e', () => 'E'), throwsStateError);
  });

  test('rejects a non-positive capacity', () {
    expect(
      () => LruResourceCache<String, String>(capacity: 0, disposeResource: (_, _) {}),
      throwsArgumentError,
    );
  });
}
