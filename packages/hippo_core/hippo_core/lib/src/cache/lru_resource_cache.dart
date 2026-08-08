/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:collection';

typedef ResourceDisposer<K, V> = void Function(K key, V value);
typedef ResourceEvictionPredicate<K, V> = bool Function(K key, V value);

/// A bounded cache for owned resources ordered from least to most recently used.
///
/// Values removed by capacity eviction, explicit removal, replacement, [clear],
/// or [dispose] are passed to [disposeResource]. Pinned values and values for
/// which [canEvict] returns `false` are skipped during capacity eviction.
/// Consequently, the cache can temporarily exceed [capacity] when no safe
/// eviction candidate exists. Call [trim] when a protected resource becomes
/// evictable.
///
/// The value inserted by [put] or [getOrCreate] is protected from eviction for
/// that operation. This ensures that those methods never return a resource that
/// was disposed immediately because all older entries were protected.
final class LruResourceCache<K extends Object, V> {
  LruResourceCache({required this.capacity, required this.disposeResource, this.canEvict}) {
    if (capacity <= 0) {
      throw ArgumentError.value(capacity, 'capacity', 'Must be greater than zero.');
    }
  }

  final int capacity;
  final ResourceDisposer<K, V> disposeResource;
  final ResourceEvictionPredicate<K, V>? canEvict;

  final LinkedHashMap<K, V> _entries = LinkedHashMap<K, V>();
  final Set<K> _pinnedKeys = <K>{};
  bool _disposed = false;

  int get length => _entries.length;
  bool get isEmpty => _entries.isEmpty;
  bool get isNotEmpty => _entries.isNotEmpty;
  bool get isOverCapacity => length > capacity;

  /// Keys ordered from least to most recently used.
  Iterable<K> get keys => _entries.keys;

  /// Values ordered from least to most recently used.
  Iterable<V> get values => _entries.values;

  bool containsKey(K key) => _entries.containsKey(key);
  bool isPinned(K key) => _pinnedKeys.contains(key);

  /// Returns and promotes the value associated with [key].
  V? get(K key) {
    _ensureNotDisposed();
    if (!_entries.containsKey(key)) return null;
    final value = _entries.remove(key) as V;
    _entries[key] = value;
    return value;
  }

  /// Returns the value associated with [key] without changing recency.
  V? peek(K key) {
    _ensureNotDisposed();
    return _entries[key];
  }

  V getOrCreate(K key, V Function() create, {bool pinned = false}) {
    _ensureNotDisposed();
    if (_entries.containsKey(key)) {
      final value = get(key) as V;
      if (pinned) _pinnedKeys.add(key);
      return value;
    }
    return put(key, create(), pinned: pinned);
  }

  /// Inserts [value], replacing and disposing a previous value for [key].
  V put(K key, V value, {bool pinned = false}) {
    _ensureNotDisposed();
    if (_entries.containsKey(key)) {
      final previous = _entries.remove(key) as V;
      if (!identical(previous, value)) disposeResource(key, previous);
    }
    _entries[key] = value;
    if (pinned) {
      _pinnedKeys.add(key);
    } else {
      _pinnedKeys.remove(key);
    }
    _trim(protectedKey: key);
    return value;
  }

  /// Removes [key], disposing its value by default.
  V? remove(K key, {bool dispose = true}) {
    _ensureNotDisposed();
    if (!_entries.containsKey(key)) return null;
    final value = _entries.remove(key) as V;
    _pinnedKeys.remove(key);
    if (dispose) disposeResource(key, value);
    return value;
  }

  /// Prevents capacity eviction of [key].
  ///
  /// Returns `false` when [key] is not cached.
  bool pin(K key) {
    _ensureNotDisposed();
    if (!_entries.containsKey(key)) return false;
    return _pinnedKeys.add(key);
  }

  /// Allows capacity eviction of [key] and trims any existing overflow.
  bool unpin(K key) {
    _ensureNotDisposed();
    final removed = _pinnedKeys.remove(key);
    if (removed) trim();
    return removed;
  }

  /// Evicts safe least-recently-used values until the capacity is restored.
  ///
  /// Returns the number of values evicted.
  int trim() {
    _ensureNotDisposed();
    return _trim();
  }

  /// Removes and disposes every cached value, including pinned values.
  void clear() {
    _ensureNotDisposed();
    _clear();
  }

  void dispose() {
    if (_disposed) return;
    _clear();
    _disposed = true;
  }

  int _trim({K? protectedKey}) {
    var evictionCount = 0;
    while (_entries.length > capacity) {
      K? candidateKey;
      for (final entry in _entries.entries) {
        if (entry.key == protectedKey ||
            _pinnedKeys.contains(entry.key) ||
            canEvict?.call(entry.key, entry.value) == false) {
          continue;
        }
        candidateKey = entry.key;
        break;
      }
      if (candidateKey == null) break;
      final value = _entries.remove(candidateKey) as V;
      _pinnedKeys.remove(candidateKey);
      disposeResource(candidateKey, value);
      evictionCount++;
    }
    return evictionCount;
  }

  void _clear() {
    final entries = _entries.entries.toList(growable: false);
    _entries.clear();
    _pinnedKeys.clear();
    for (final entry in entries) {
      disposeResource(entry.key, entry.value);
    }
  }

  void _ensureNotDisposed() {
    if (_disposed) throw StateError('The cache has been disposed.');
  }
}
