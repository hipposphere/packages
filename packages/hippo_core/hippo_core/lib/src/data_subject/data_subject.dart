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

import 'package:rxdart/rxdart.dart';

import 'data_value.dart';

/// A writable reactive value backed by a [BehaviorSubject].
class DataSubject<T> implements DataValue<T> {
  final BehaviorSubject<T> _subject = BehaviorSubject<T>();

  DataSubject.empty();

  DataSubject.seeded(T seedValue) {
    _subject.add(seedValue);
  }

  DataSubject.fromStream(Stream<T> stream) {
    _subject.addStream(stream);
  }

  @Deprecated('Use DataSubject directly. The underlying BehaviorSubject will become private.')
  BehaviorSubject<T> get subject => _subject;

  @override
  Stream<T> get stream => _subject.stream;

  @override
  T get value {
    if (!_subject.hasValue) {
      throw StateError('The DataSubject does not have a value yet.');
    }
    return _subject.value;
  }

  @override
  T? get valueOrNull => _subject.valueOrNull;

  void add(T data) {
    _subject.add(data);
  }

  void addError(Object error, [StackTrace? stackTrace]) {
    _subject.addError(error, stackTrace);
  }

  Future<void> addStream(Stream<T> stream) async {
    await _subject.addStream(stream);
  }

  Future<void> close() => _subject.close();

  bool get isClosed => _subject.isClosed;

  @override
  bool get hasValue => _subject.hasValue;

  StreamSubscription<T> listen(
    void Function(T data) onData, {
    Function? onError,
    void Function()? onDone,
    bool cancelOnError = false,
  }) {
    return _subject.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
