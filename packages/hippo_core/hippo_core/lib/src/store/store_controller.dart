import 'dart:async';
import 'dart:convert';

import 'package:hippo_core/hippo_core.dart';

/// A controller for a key-value store that manages a single value of type [T].
///
/// JSON encoding and decoding is used to store complex data structures as
/// strings. Values are published optimistically before their corresponding
/// writes complete, while persistence operations are kept in invocation order.
class StoreController<T> {
  StoreController({
    required this._keyValueStore,
    required this._storeKey,
    required this._defaultValue,
    required this._itemDecoder,
    required this._itemEncoder,
    T? initialValue,
    bool initializeOnCreation = true,
  }) {
    subject.add(initialValue);
    if (initializeOnCreation) {
      final initialization = initialize();
      // Loading errors are also emitted by [subject] and remain observable
      // through [ready]. Avoid reporting the automatically started future as
      // an additional unhandled asynchronous error.
      unawaited(initialization.then<void>((_) {}, onError: (Object _, StackTrace _) {}));
    }
  }

  final KeyValueStore _keyValueStore;
  final ItemDecoder<T> _itemDecoder;
  final ItemEncoder<T> _itemEncoder;
  final String _storeKey;
  final T _defaultValue;
  final subject = DataSubject<T?>.empty();
  Future<void>? _initialization;
  Future<void> _writeQueue = Future<void>.value();
  var _revision = 0;
  var _disposed = false;

  /// Completes after the stored value has been loaded.
  ///
  /// Accessing this starts initialization when [initializeOnCreation] was
  /// disabled. Initialization is performed at most once.
  Future<void> get ready => initialize();

  /// Throws if the current value is null.
  ///
  /// This can happen before initialization completes when no [initialValue]
  /// was supplied.
  T get currentValue => subject.value!;

  bool get hasValue => subject.hasValue;

  /// Loads the persisted value once.
  ///
  /// A value passed to [update] while loading remains authoritative when the
  /// read completes, preventing stale storage from replacing newer state.
  Future<void> initialize() {
    _ensureNotDisposed();
    return _initialization ??= _initialize();
  }

  /// Publishes [newValue] immediately and persists it in invocation order.
  Future<void> update(T newValue) {
    _ensureNotDisposed();
    _revision += 1;
    subject.add(newValue);
    return _enqueueWrite(() => _storeValue(newValue));
  }

  Future<void> updateBuilder({required T Function(T currentValue) builder}) {
    final newValue = builder(currentValue);
    return update(newValue);
  }

  Future<void> _initialize() async {
    final revision = _revision;
    try {
      final value = await _getStoredValue();
      if (!_disposed && revision == _revision) {
        subject.add(value);
      }
    } on Object catch (error, stackTrace) {
      if (!_disposed && revision == _revision) {
        subject.addError(error, stackTrace);
      }
      rethrow;
    }
  }

  Future<T> _getStoredValue() async {
    final data = await _keyValueStore.getString(_storeKey);
    if (data == null) {
      return _defaultValue;
    }
    return _itemDecoder(jsonDecode(data));
  }

  Future<void> _storeValue(T value) async {
    await _keyValueStore.setString(_storeKey, jsonEncode(_itemEncoder(value)));
  }

  Future<void> _enqueueWrite(Future<void> Function() operation) {
    final result = _writeQueue.then((_) => operation());
    _writeQueue = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    subject.close();
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('StoreController has been disposed.');
    }
  }
}
