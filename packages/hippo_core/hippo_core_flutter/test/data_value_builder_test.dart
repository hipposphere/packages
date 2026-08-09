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
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

void main() {
  testWidgets('renders empty, seeded-null, and later data distinctly', (tester) async {
    final subject = DataSubject<String?>.empty();

    await tester.pumpWidget(_TestHost(subject: subject));
    expect(find.text('empty'), findsOneWidget);

    subject.add(null);
    await _pumpDataEvent(tester);
    expect(find.text('value:null'), findsOneWidget);

    subject.add('ready');
    await _pumpDataEvent(tester);
    expect(find.text('value:ready'), findsOneWidget);

    await subject.close();
  });

  testWidgets('shows errors with stack traces and recovers on data', (tester) async {
    final subject = DataSubject<String>.seeded('previous');
    final stackTrace = StackTrace.current;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DataValueBuilder<String>(
          value: subject,
          builder: (context, value) => Text('value:$value'),
          errorBuilder: (context, error, emittedStackTrace) {
            expect(emittedStackTrace, same(stackTrace));
            return Text('error:$error');
          },
        ),
      ),
    );

    subject.addError('failed', stackTrace);
    await _pumpDataEvent(tester);
    expect(find.text('error:failed'), findsOneWidget);

    subject.add('recovered');
    await _pumpDataEvent(tester);
    expect(find.text('value:recovered'), findsOneWidget);

    await subject.close();
  });

  testWidgets('keeps previous data when no error builder is supplied', (tester) async {
    final subject = DataSubject<String>.seeded('previous');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DataValueBuilder<String>(
          value: subject,
          builder: (context, value) => Text('value:$value'),
        ),
      ),
    );

    subject.addError(StateError('failed'));
    await _pumpDataEvent(tester);

    expect(find.text('value:previous'), findsOneWidget);
    await subject.close();
  });

  testWidgets('resubscribes when the supplied value changes', (tester) async {
    final first = DataSubject<String>.seeded('first');
    final second = DataSubject<String>.seeded('second');

    await tester.pumpWidget(_TestHost(subject: first));
    expect(find.text('value:first'), findsOneWidget);

    await tester.pumpWidget(_TestHost(subject: second));
    expect(find.text('value:second'), findsOneWidget);

    first.add('stale');
    second.add('current');
    await _pumpDataEvent(tester);
    expect(find.text('value:current'), findsOneWidget);
    expect(find.text('value:stale'), findsNothing);

    await first.close();
    await second.close();
  });

  testWidgets('selected values skip equivalent rebuilds', (tester) async {
    final subject = DataSubject<List<int>>.seeded([1]);
    final selected = DataValues.select<List<int>, int>(subject, (value) => value.length);
    var buildCount = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DataValueBuilder<int>(
          value: selected,
          builder: (context, value) {
            buildCount += 1;
            return Text('$value');
          },
        ),
      ),
    );
    await tester.pump();
    final initialBuildCount = buildCount;

    subject.add([2]);
    await _pumpDataEvent(tester);
    expect(buildCount, initialBuildCount);

    subject.add([2, 3]);
    await _pumpDataEvent(tester);
    expect(buildCount, initialBuildCount + 1);

    await subject.close();
  });

  testWidgets('compatibility combined builder supports nullable values', (tester) async {
    final first = DataSubject<String?>.seeded(null);
    final second = DataSubject<int>.seeded(2);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: CombinedDataSubjectBuilder<String?, int>(
          subject1: first,
          subject2: second,
          builder: (context, firstValue, secondValue) => Text('$firstValue:$secondValue'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('null:2'), findsOneWidget);

    await first.close();
    await second.close();
  });

  testWidgets('combined value builder preserves subscriptions across parent rebuilds', (
    tester,
  ) async {
    final firstSubject = DataSubject<String>.seeded('first');
    final secondSubject = DataSubject<int>.seeded(2);
    final first = _TrackingDataValue(firstSubject);
    final second = _TrackingDataValue(secondSubject);

    await tester.pumpWidget(_CombinedHost(first: first, second: second));
    await tester.pump();
    expect(find.text('first:2'), findsOneWidget);
    expect(first.listenCount, 1);
    expect(second.listenCount, 1);

    await tester.pumpWidget(_CombinedHost(first: first, second: second));
    await tester.pump();
    expect(first.listenCount, 1);
    expect(second.listenCount, 1);

    await firstSubject.close();
    await secondSubject.close();
  });

  testWidgets('combined value builder replaces changed sources', (tester) async {
    final oldFirst = DataSubject<String>.seeded('old');
    final newFirst = DataSubject<String>.seeded('new');
    final second = DataSubject<int>.seeded(2);

    await tester.pumpWidget(_CombinedHost(first: oldFirst, second: second));
    await tester.pump();
    expect(find.text('old:2'), findsOneWidget);

    await tester.pumpWidget(_CombinedHost(first: newFirst, second: second));
    await tester.pump();
    expect(find.text('new:2'), findsOneWidget);

    oldFirst.add('stale');
    newFirst.add('current');
    await _pumpDataEvent(tester);
    expect(find.text('current:2'), findsOneWidget);
    expect(find.text('stale:2'), findsNothing);

    await oldFirst.close();
    await newFirst.close();
    await second.close();
  });

  testWidgets('three and four value builders expose each typed value', (tester) async {
    final first = DataSubject<String>.seeded('one');
    final second = DataSubject<int>.seeded(2);
    final third = DataSubject<bool>.seeded(true);
    final fourth = DataSubject<double>.seeded(4.5);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            CombinedDataValueBuilder3<String, int, bool>(
              value1: first,
              value2: second,
              value3: third,
              builder: (context, a, b, c) => Text('$a:$b:$c'),
            ),
            CombinedDataValueBuilder4<String, int, bool, double>(
              value1: first,
              value2: second,
              value3: third,
              value4: fourth,
              builder: (context, a, b, c, d) => Text('$a:$b:$c:$d'),
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.text('one:2:true'), findsOneWidget);
    expect(find.text('one:2:true:4.5'), findsOneWidget);

    await first.close();
    await second.close();
    await third.close();
    await fourth.close();
  });
}

class _TestHost extends StatelessWidget {
  const _TestHost({required this.subject});

  final DataValue<String?> subject;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: DataValueBuilder<String?>(
        value: subject,
        emptyBuilder: (context) => const Text('empty'),
        builder: (context, value) => Text('value:$value'),
      ),
    );
  }
}

class _CombinedHost extends StatelessWidget {
  const _CombinedHost({required this.first, required this.second});

  final DataValue<String> first;
  final DataValue<int> second;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CombinedDataValueBuilder<String, int>(
        value1: first,
        value2: second,
        builder: (context, firstValue, secondValue) => Text('$firstValue:$secondValue'),
      ),
    );
  }
}

class _TrackingDataValue<T> implements DataValue<T> {
  _TrackingDataValue(this._delegate) {
    _stream = Stream<T>.multi((controller) {
      listenCount += 1;
      final subscription = _delegate.stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );
      controller.onCancel = subscription.cancel;
    });
  }

  final DataValue<T> _delegate;
  late final Stream<T> _stream;
  var listenCount = 0;

  @override
  bool get hasValue => _delegate.hasValue;

  @override
  Stream<T> get stream => _stream;

  @override
  T get value => _delegate.value;

  @override
  T? get valueOrNull => _delegate.valueOrNull;
}

Future<void> _pumpDataEvent(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}
