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
  test('DataSubject distinguishes an absent value from a seeded null', () async {
    final empty = DataSubject<String?>.empty();
    final seededNull = DataSubject<String?>.seeded(null);

    expect(empty.hasValue, isFalse);
    expect(empty.valueOrNull, isNull);
    expect(() => empty.value, throwsA(isA<StateError>()));
    expect(seededNull.hasValue, isTrue);
    expect(seededNull.value, isNull);

    await empty.close();
    await seededNull.close();
  });

  test('DataSubject preserves error stack traces', () async {
    final subject = DataSubject<int>.empty();
    final stackTrace = StackTrace.current;
    final errorEvent = subject.stream.handleError((Object _, StackTrace emittedStackTrace) {
      expect(emittedStackTrace, same(stackTrace));
    }).drain<void>();

    subject.addError(StateError('failed'), stackTrace);
    await subject.close();
    await errorEvent;
  });

  test('combine values expose synchronous records and distinct updates', () async {
    final first = DataSubject<int>.seeded(1);
    final second = DataSubject<String>.seeded('a');
    final combined = DataValues.combine2(first, second);

    expect(combined.hasValue, isTrue);
    expect(combined.value, (1, 'a'));

    final events = <(int, String)>[];
    final subscription = combined.stream.listen(events.add);
    await Future<void>.delayed(Duration.zero);
    first
      ..add(1)
      ..add(2);
    await Future<void>.delayed(Duration.zero);
    second.add('b');
    await Future<void>.delayed(Duration.zero);

    expect(events, [(1, 'a'), (2, 'a'), (2, 'b')]);

    await subscription.cancel();
    await first.close();
    await second.close();
  });

  test('computed values wait until every source has data', () async {
    final first = DataSubject<int>.seeded(2);
    final second = DataSubject<int>.empty();
    final computed = DataValues.compute2(first, second, (first, second) => first + second);

    expect(computed.hasValue, isFalse);
    expect(computed.valueOrNull, isNull);
    expect(() => computed.value, throwsStateError);

    final firstEvent = computed.stream.first;
    second.add(3);
    expect(await firstEvent, 5);

    await first.close();
    await second.close();
  });

  test('computeList derives dependencies directly from a homogeneous source list', () async {
    final first = DataSubject<int>.seeded(1);
    final second = DataSubject<int>.seeded(2);
    final total = DataValues.computeList<int, int>([
      first,
      second,
    ], (values) => values.reduce((a, b) => a + b));
    final events = <int>[];
    final subscription = total.stream.listen(events.add);
    await Future<void>.delayed(Duration.zero);

    second.add(4);
    await Future<void>.delayed(Duration.zero);

    expect(total.value, 5);
    expect(events, [3, 5]);
    await subscription.cancel();
    await first.close();
    await second.close();
  });

  test('compute10 exposes every typed source to its computation', () async {
    final subjects = [for (var value = 1; value <= 10; value += 1) DataSubject<int>.seeded(value)];
    final total = DataValues.compute10(
      subjects[0],
      subjects[1],
      subjects[2],
      subjects[3],
      subjects[4],
      subjects[5],
      subjects[6],
      subjects[7],
      subjects[8],
      subjects[9],
      (a, b, c, d, e, f, g, h, i, j) => a + b + c + d + e + f + g + h + i + j,
    );

    expect(total.value, 55);
    subjects[9].add(20);
    expect(total.value, 65);

    for (final subject in subjects) {
      await subject.close();
    }
  });

  test('computeList rejects an empty source list', () {
    expect(
      () => DataValues.computeList<int, int>(const [], (values) => values.length),
      throwsArgumentError,
    );
  });

  test('select supports custom equality', () async {
    final subject = DataSubject<List<int>>.seeded([1]);
    final lengths = DataValues.select<List<int>, int>(subject, (value) => value.length);
    final events = <int>[];
    final subscription = lengths.stream.listen(events.add);
    await Future<void>.delayed(Duration.zero);

    subject
      ..add([2])
      ..add([2, 3]);
    await Future<void>.delayed(Duration.zero);

    expect(events, [1, 2]);

    await subscription.cancel();
    await subject.close();
  });

  test('computed values subscribe lazily and release their sources', () async {
    final sourceController = StreamController<int>.broadcast();
    var listeners = 0;
    final source = _TestDataValue<int>(
      stream: sourceController.stream.transform(
        StreamTransformer.fromHandlers(handleData: (data, sink) => sink.add(data)),
      ),
      onListen: () => listeners += 1,
      onCancel: () => listeners -= 1,
    );
    final selected = DataValues.select<int, int>(source, (value) => value * 2);

    expect(listeners, 0);
    final subscription = selected.stream.listen((_) {});
    await Future<void>.delayed(Duration.zero);
    expect(listeners, 1);

    await subscription.cancel();
    expect(listeners, 0);
    await sourceController.close();
  });
}

final class _TestDataValue<T> implements DataValue<T> {
  _TestDataValue({
    required Stream<T> stream,
    required void Function() onListen,
    required void Function() onCancel,
  }) : stream = stream.asBroadcastStream(onListen: (_) => onListen(), onCancel: (_) => onCancel());

  @override
  final Stream<T> stream;

  @override
  bool get hasValue => true;

  @override
  T get value => 1 as T;

  @override
  T? get valueOrNull => value;
}
