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

import 'package:flutter/widgets.dart';
import 'package:hippo_core/hippo_core.dart';

typedef DataValueErrorBuilder =
    Widget Function(BuildContext context, Object error, StackTrace? stackTrace);

/// Builds from the latest value of a read-only [DataValue].
///
/// Unlike [StreamBuilder], this uses [DataValue.hasValue] to distinguish an
/// absent value from a valid nullable value. It also resubscribes when [value]
/// changes and gives errors precedence when [errorBuilder] is supplied.
class DataValueBuilder<T> extends StatefulWidget {
  const DataValueBuilder({
    super.key,
    required this.value,
    required this.builder,
    this.emptyBuilder,
    this.errorBuilder,
  });

  final DataValue<T> value;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final DataValueErrorBuilder? errorBuilder;

  @override
  State<DataValueBuilder<T>> createState() => _DataValueBuilderState<T>();
}

class _DataValueBuilderState<T> extends State<DataValueBuilder<T>> {
  StreamSubscription<T>? _subscription;
  T? _data;
  Object? _error;
  StackTrace? _stackTrace;
  var _hasValue = false;
  var _subscriptionGeneration = 0;

  @override
  void initState() {
    super.initState();
    _readCurrentValue();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant DataValueBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.value, widget.value)) {
      return;
    }
    _subscriptionGeneration += 1;
    unawaited(_subscription?.cancel());
    _readCurrentValue();
    _subscribe();
  }

  void _readCurrentValue() {
    _hasValue = widget.value.hasValue;
    _data = widget.value.valueOrNull;
    _error = null;
    _stackTrace = null;
  }

  void _subscribe() {
    final generation = _subscriptionGeneration;
    _subscription = widget.value.stream.listen(
      (data) {
        if (!mounted || generation != _subscriptionGeneration) return;
        setState(() {
          _hasValue = true;
          _data = data;
          _error = null;
          _stackTrace = null;
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!mounted || generation != _subscriptionGeneration) return;
        setState(() {
          _error = error;
          _stackTrace = stackTrace;
        });
      },
    );
  }

  @override
  void dispose() {
    _subscriptionGeneration += 1;
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    final errorBuilder = widget.errorBuilder;
    if (error != null && errorBuilder != null) {
      return errorBuilder(context, error, _stackTrace);
    }
    if (_hasValue) {
      return widget.builder(context, _data as T);
    }
    return widget.emptyBuilder?.call(context) ?? const SizedBox.shrink();
  }
}

/// Compatibility builder for writable [DataSubject] and read-only [DataValue]
/// instances.
///
/// Prefer [DataValueBuilder] for new code to make read-only intent explicit.
class DataSubjectBuilder<T> extends StatelessWidget {
  const DataSubjectBuilder({
    super.key,
    required this.subject,
    required this.builder,
    this.emptyBuilder,
    this.errorBuilder,
  });

  final DataValue<T> subject;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context, Object? error)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return DataValueBuilder<T>(
      value: subject,
      builder: builder,
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder == null
          ? null
          : (context, error, _) => errorBuilder!(context, error),
    );
  }
}

@Deprecated('Use DataValueBuilder. It handles value replacement correctly.')
class StatefulDataSubjectBuilder<T> extends DataSubjectBuilder<T> {
  const StatefulDataSubjectBuilder({
    super.key,
    required super.subject,
    required super.builder,
    super.emptyBuilder,
    super.errorBuilder,
  });
}

/// Builds from two widget-local [DataValue] instances.
///
/// The combined value is preserved across parent rebuilds and recreated only
/// when one of the supplied value identities changes. Prefer a bloc-owned
/// `DataValues.combine2` value when the combination is reusable view state.
class CombinedDataValueBuilder<T1, T2> extends StatelessWidget {
  const CombinedDataValueBuilder({
    super.key,
    required this.value1,
    required this.value2,
    required this.builder,
    this.emptyBuilder,
    this.errorBuilder,
  });

  final DataValue<T1> value1;
  final DataValue<T2> value2;
  final Widget Function(BuildContext context, T1 data1, T2 data2) builder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final DataValueErrorBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return _CombinedDataValueBuilder<(T1, T2)>(
      sources: <DataValue<Object?>>[value1, value2],
      combine: () => DataValues.combine2(value1, value2),
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder,
      builder: (context, data) => builder(context, data.$1, data.$2),
    );
  }
}

/// Builds from three widget-local [DataValue] instances.
class CombinedDataValueBuilder3<T1, T2, T3> extends StatelessWidget {
  const CombinedDataValueBuilder3({
    super.key,
    required this.value1,
    required this.value2,
    required this.value3,
    required this.builder,
    this.emptyBuilder,
    this.errorBuilder,
  });

  final DataValue<T1> value1;
  final DataValue<T2> value2;
  final DataValue<T3> value3;
  final Widget Function(BuildContext context, T1 data1, T2 data2, T3 data3) builder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final DataValueErrorBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return _CombinedDataValueBuilder<(T1, T2, T3)>(
      sources: <DataValue<Object?>>[value1, value2, value3],
      combine: () => DataValues.combine3(value1, value2, value3),
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder,
      builder: (context, data) => builder(context, data.$1, data.$2, data.$3),
    );
  }
}

/// Builds from four widget-local [DataValue] instances.
class CombinedDataValueBuilder4<T1, T2, T3, T4> extends StatelessWidget {
  const CombinedDataValueBuilder4({
    super.key,
    required this.value1,
    required this.value2,
    required this.value3,
    required this.value4,
    required this.builder,
    this.emptyBuilder,
    this.errorBuilder,
  });

  final DataValue<T1> value1;
  final DataValue<T2> value2;
  final DataValue<T3> value3;
  final DataValue<T4> value4;
  final Widget Function(BuildContext context, T1 data1, T2 data2, T3 data3, T4 data4) builder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final DataValueErrorBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return _CombinedDataValueBuilder<(T1, T2, T3, T4)>(
      sources: <DataValue<Object?>>[value1, value2, value3, value4],
      combine: () => DataValues.combine4(value1, value2, value3, value4),
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder,
      builder: (context, data) => builder(context, data.$1, data.$2, data.$3, data.$4),
    );
  }
}

class _CombinedDataValueBuilder<T> extends StatefulWidget {
  const _CombinedDataValueBuilder({
    required this.sources,
    required this.combine,
    required this.builder,
    this.emptyBuilder,
    this.errorBuilder,
  });

  final List<DataValue<Object?>> sources;
  final DataValue<T> Function() combine;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final DataValueErrorBuilder? errorBuilder;

  @override
  State<_CombinedDataValueBuilder<T>> createState() => _CombinedDataValueBuilderState<T>();
}

class _CombinedDataValueBuilderState<T> extends State<_CombinedDataValueBuilder<T>> {
  late DataValue<T> _value;

  @override
  void initState() {
    super.initState();
    _value = widget.combine();
  }

  @override
  void didUpdateWidget(covariant _CombinedDataValueBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_haveIdenticalValues(oldWidget.sources, widget.sources)) {
      _value = widget.combine();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DataValueBuilder<T>(
      value: _value,
      builder: widget.builder,
      emptyBuilder: widget.emptyBuilder,
      errorBuilder: widget.errorBuilder,
    );
  }
}

bool _haveIdenticalValues(List<DataValue<Object?>> first, List<DataValue<Object?>> second) {
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index += 1) {
    if (!identical(first[index], second[index])) return false;
  }
  return true;
}

/// Compatibility wrapper for [CombinedDataValueBuilder].
@Deprecated('Use CombinedDataValueBuilder.')
class CombinedDataSubjectBuilder<T1, T2> extends StatelessWidget {
  const CombinedDataSubjectBuilder({
    super.key,
    required this.subject1,
    required this.subject2,
    required this.builder,
    this.emptyBuilder,
    this.errorBuilder,
  });

  final DataValue<T1> subject1;
  final DataValue<T2> subject2;
  final Widget Function(BuildContext context, T1 data1, T2 data2) builder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final DataValueErrorBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return CombinedDataValueBuilder<T1, T2>(
      value1: subject1,
      value2: subject2,
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder,
      builder: builder,
    );
  }
}

/// Compatibility wrapper for [CombinedDataValueBuilder3].
@Deprecated('Use CombinedDataValueBuilder3.')
class Combine3DataSubjectBuilder<T1, T2, T3> extends StatelessWidget {
  const Combine3DataSubjectBuilder({
    super.key,
    required this.subject1,
    required this.subject2,
    required this.subject3,
    required this.builder,
    this.emptyBuilder,
    this.errorBuilder,
  });

  final DataValue<T1> subject1;
  final DataValue<T2> subject2;
  final DataValue<T3> subject3;
  final Widget Function(BuildContext context, T1 data1, T2 data2, T3 data3) builder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final DataValueErrorBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return CombinedDataValueBuilder3<T1, T2, T3>(
      value1: subject1,
      value2: subject2,
      value3: subject3,
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder,
      builder: builder,
    );
  }
}

/// Compatibility wrapper for [CombinedDataValueBuilder4].
@Deprecated('Use CombinedDataValueBuilder4.')
class Combine4DataSubjectBuilder<T1, T2, T3, T4> extends StatelessWidget {
  const Combine4DataSubjectBuilder({
    super.key,
    required this.subject1,
    required this.subject2,
    required this.subject3,
    required this.subject4,
    required this.builder,
    this.emptyBuilder,
    this.errorBuilder,
  });

  final DataValue<T1> subject1;
  final DataValue<T2> subject2;
  final DataValue<T3> subject3;
  final DataValue<T4> subject4;
  final Widget Function(BuildContext context, T1 data1, T2 data2, T3 data3, T4 data4) builder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final DataValueErrorBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return CombinedDataValueBuilder4<T1, T2, T3, T4>(
      value1: subject1,
      value2: subject2,
      value3: subject3,
      value4: subject4,
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder,
      builder: builder,
    );
  }
}

@Deprecated('Use a TextEditingController and a separate DataSubject explicitly.')
class TextEditingDataSubject extends DataSubject<String> {
  TextEditingDataSubject.empty() : textEditingController = TextEditingController(), super.empty();

  TextEditingDataSubject.seeded(super.seedValue)
    : textEditingController = TextEditingController(text: seedValue),
      super.seeded();

  final TextEditingController textEditingController;
  final errorSubject = DataSubject<String?>.seeded(null);
  var _closed = false;

  void setText(String text) {
    textEditingController.text = text;
    add(text);
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    textEditingController.dispose();
    await errorSubject.close();
    await super.close();
  }
}
