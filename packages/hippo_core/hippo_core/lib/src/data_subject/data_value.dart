/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:rxdart/rxdart.dart';

/// A read-only reactive value with synchronous access to its latest data.
abstract interface class DataValue<T> {
  /// Emits value changes and source errors.
  Stream<T> get stream;

  /// Whether a value has been emitted or seeded.
  bool get hasValue;

  /// The latest value.
  ///
  /// Throws a [StateError] when [hasValue] is false.
  T get value;

  /// The latest value, or `null` when [hasValue] is false.
  ///
  /// Use [hasValue] to distinguish an absent value from a valid nullable value.
  T? get valueOrNull;
}

/// Creates lazy read-only values derived from one or more [DataValue] sources.
abstract final class DataValues {
  /// Computes a value from two typed sources.
  static DataValue<T> compute2<A, B, T>(
    DataValue<A> first,
    DataValue<B> second,
    T Function(A first, B second) compute, {
    bool Function(T previous, T next)? equals,
  }) {
    return _compute<T>(
      sources: [first, second],
      read: () => compute(first.value, second.value),
      equals: equals,
    );
  }

  /// Computes a value from three typed sources.
  static DataValue<T> compute3<A, B, C, T>(
    DataValue<A> first,
    DataValue<B> second,
    DataValue<C> third,
    T Function(A first, B second, C third) compute, {
    bool Function(T previous, T next)? equals,
  }) {
    return _compute<T>(
      sources: [first, second, third],
      read: () => compute(first.value, second.value, third.value),
      equals: equals,
    );
  }

  /// Computes a value from four typed sources.
  static DataValue<T> compute4<A, B, C, D, T>(
    DataValue<A> first,
    DataValue<B> second,
    DataValue<C> third,
    DataValue<D> fourth,
    T Function(A first, B second, C third, D fourth) compute, {
    bool Function(T previous, T next)? equals,
  }) {
    return _compute<T>(
      sources: [first, second, third, fourth],
      read: () => compute(first.value, second.value, third.value, fourth.value),
      equals: equals,
    );
  }

  /// Computes a value from five typed sources.
  static DataValue<T> compute5<A, B, C, D, E, T>(
    DataValue<A> first,
    DataValue<B> second,
    DataValue<C> third,
    DataValue<D> fourth,
    DataValue<E> fifth,
    T Function(A first, B second, C third, D fourth, E fifth) compute, {
    bool Function(T previous, T next)? equals,
  }) {
    return _compute<T>(
      sources: [first, second, third, fourth, fifth],
      read: () => compute(first.value, second.value, third.value, fourth.value, fifth.value),
      equals: equals,
    );
  }

  /// Computes a value from six typed sources.
  static DataValue<T> compute6<A, B, C, D, E, F, T>(
    DataValue<A> first,
    DataValue<B> second,
    DataValue<C> third,
    DataValue<D> fourth,
    DataValue<E> fifth,
    DataValue<F> sixth,
    T Function(A first, B second, C third, D fourth, E fifth, F sixth) compute, {
    bool Function(T previous, T next)? equals,
  }) {
    return _compute<T>(
      sources: [first, second, third, fourth, fifth, sixth],
      read: () =>
          compute(first.value, second.value, third.value, fourth.value, fifth.value, sixth.value),
      equals: equals,
    );
  }

  /// Computes a value from seven typed sources.
  static DataValue<T> compute7<A, B, C, D, E, F, G, T>(
    DataValue<A> first,
    DataValue<B> second,
    DataValue<C> third,
    DataValue<D> fourth,
    DataValue<E> fifth,
    DataValue<F> sixth,
    DataValue<G> seventh,
    T Function(A first, B second, C third, D fourth, E fifth, F sixth, G seventh) compute, {
    bool Function(T previous, T next)? equals,
  }) {
    return _compute<T>(
      sources: [first, second, third, fourth, fifth, sixth, seventh],
      read: () => compute(
        first.value,
        second.value,
        third.value,
        fourth.value,
        fifth.value,
        sixth.value,
        seventh.value,
      ),
      equals: equals,
    );
  }

  /// Computes a value from eight typed sources.
  static DataValue<T> compute8<A, B, C, D, E, F, G, H, T>(
    DataValue<A> first,
    DataValue<B> second,
    DataValue<C> third,
    DataValue<D> fourth,
    DataValue<E> fifth,
    DataValue<F> sixth,
    DataValue<G> seventh,
    DataValue<H> eighth,
    T Function(A first, B second, C third, D fourth, E fifth, F sixth, G seventh, H eighth)
    compute, {
    bool Function(T previous, T next)? equals,
  }) {
    return _compute<T>(
      sources: [first, second, third, fourth, fifth, sixth, seventh, eighth],
      read: () => compute(
        first.value,
        second.value,
        third.value,
        fourth.value,
        fifth.value,
        sixth.value,
        seventh.value,
        eighth.value,
      ),
      equals: equals,
    );
  }

  /// Computes a value from nine typed sources.
  static DataValue<T> compute9<A, B, C, D, E, F, G, H, I, T>(
    DataValue<A> first,
    DataValue<B> second,
    DataValue<C> third,
    DataValue<D> fourth,
    DataValue<E> fifth,
    DataValue<F> sixth,
    DataValue<G> seventh,
    DataValue<H> eighth,
    DataValue<I> ninth,
    T Function(A first, B second, C third, D fourth, E fifth, F sixth, G seventh, H eighth, I ninth)
    compute, {
    bool Function(T previous, T next)? equals,
  }) {
    return _compute<T>(
      sources: [first, second, third, fourth, fifth, sixth, seventh, eighth, ninth],
      read: () => compute(
        first.value,
        second.value,
        third.value,
        fourth.value,
        fifth.value,
        sixth.value,
        seventh.value,
        eighth.value,
        ninth.value,
      ),
      equals: equals,
    );
  }

  /// Computes a value from ten typed sources.
  static DataValue<T> compute10<A, B, C, D, E, F, G, H, I, J, T>(
    DataValue<A> first,
    DataValue<B> second,
    DataValue<C> third,
    DataValue<D> fourth,
    DataValue<E> fifth,
    DataValue<F> sixth,
    DataValue<G> seventh,
    DataValue<H> eighth,
    DataValue<I> ninth,
    DataValue<J> tenth,
    T Function(
      A first,
      B second,
      C third,
      D fourth,
      E fifth,
      F sixth,
      G seventh,
      H eighth,
      I ninth,
      J tenth,
    )
    compute, {
    bool Function(T previous, T next)? equals,
  }) {
    return _compute<T>(
      sources: [first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth],
      read: () => compute(
        first.value,
        second.value,
        third.value,
        fourth.value,
        fifth.value,
        sixth.value,
        seventh.value,
        eighth.value,
        ninth.value,
        tenth.value,
      ),
      equals: equals,
    );
  }

  /// Computes a value from a non-empty homogeneous source list.
  static DataValue<T> computeList<S, T>(
    Iterable<DataValue<S>> sources,
    T Function(List<S> values) compute, {
    bool Function(T previous, T next)? equals,
  }) {
    final sourceList = List<DataValue<S>>.unmodifiable(sources);
    return _compute<T>(
      sources: sourceList,
      read: () => compute(List<S>.unmodifiable(sourceList.map((source) => source.value))),
      equals: equals,
    );
  }

  /// Maps [source] into a distinct derived value.
  static DataValue<T> select<S, T>(
    DataValue<S> source,
    T Function(S value) selector, {
    bool Function(T previous, T next)? equals,
  }) {
    return _compute<T>(
      sources: <DataValue<Object?>>[source],
      read: () => selector(source.value),
      equals: equals,
    );
  }

  static DataValue<(A, B)> combine2<A, B>(DataValue<A> first, DataValue<B> second) {
    return compute2(first, second, (first, second) => (first, second));
  }

  static DataValue<(A, B, C)> combine3<A, B, C>(
    DataValue<A> first,
    DataValue<B> second,
    DataValue<C> third,
  ) {
    return compute3(first, second, third, (first, second, third) => (first, second, third));
  }

  static DataValue<(A, B, C, D)> combine4<A, B, C, D>(
    DataValue<A> first,
    DataValue<B> second,
    DataValue<C> third,
    DataValue<D> fourth,
  ) {
    return compute4(
      first,
      second,
      third,
      fourth,
      (first, second, third, fourth) => (first, second, third, fourth),
    );
  }

  static DataValue<T> _compute<T>({
    required Iterable<DataValue<Object?>> sources,
    required T Function() read,
    bool Function(T previous, T next)? equals,
  }) {
    return _ComputedDataValue<T>(sources, read, equals);
  }
}

final class _ComputedDataValue<T> implements DataValue<T> {
  _ComputedDataValue(Iterable<DataValue<Object?>> sources, this._read, this._equals)
    : _sources = List<DataValue<Object?>>.unmodifiable(sources) {
    if (_sources.isEmpty) {
      throw ArgumentError.value(sources, 'sources', 'Must contain at least one data value.');
    }
  }

  final List<DataValue<Object?>> _sources;
  final T Function() _read;
  final bool Function(T previous, T next)? _equals;

  @override
  bool get hasValue => _sources.every((source) => source.hasValue);

  @override
  T get value {
    if (!hasValue) {
      throw StateError('The derived DataValue does not have a value yet.');
    }
    return _read();
  }

  @override
  T? get valueOrNull => hasValue ? _read() : null;

  @override
  Stream<T> get stream {
    final changes = MergeStream<void>([
      for (final source in _sources) source.stream.map<void>((_) {}),
    ]);
    return changes
        .where((_) => hasValue)
        .map((_) => _read())
        .distinct((previous, next) => _equals?.call(previous, next) ?? previous == next);
  }
}
