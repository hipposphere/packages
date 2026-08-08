import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

class _TestBloc extends BlocBase {
  var disposeCount = 0;

  @override
  void dispose() {
    disposeCount++;
  }
}

void main() {
  testWidgets('BlocProvider exposes a bloc by type', (tester) async {
    final bloc = _TestBloc();

    await tester.pumpWidget(
      BlocProvider<_TestBloc>(
        bloc: bloc,
        child: Builder(
          builder: (context) {
            expect(BlocProvider.of<_TestBloc>(context), same(bloc));
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  testWidgets('OwnedBlocProvider creates once across rebuilds and disposes on unmount', (
    tester,
  ) async {
    var createCount = 0;
    late _TestBloc bloc;

    Widget buildProvider(String label) {
      return OwnedBlocProvider<_TestBloc>(
        create: () {
          createCount++;
          return bloc = _TestBloc();
        },
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              expect(BlocProvider.of<_TestBloc>(context), same(bloc));
              return Text(label);
            },
          ),
        ),
      );
    }

    await tester.pumpWidget(buildProvider('first'));
    expect(createCount, 1);
    expect(bloc.disposeCount, 0);

    await tester.pumpWidget(buildProvider('second'));
    expect(createCount, 1);
    expect(bloc.disposeCount, 0);
    expect(find.text('second'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(bloc.disposeCount, 1);
  });

  testWidgets('OwnedBlocProvider.builder passes the exposed owned instance', (tester) async {
    late _TestBloc bloc;

    await tester.pumpWidget(
      OwnedBlocProvider<_TestBloc>.builder(
        create: () => bloc = _TestBloc(),
        builder: (context, ownedBloc) {
          expect(ownedBloc, same(bloc));
          expect(BlocProvider.of<_TestBloc>(context), same(bloc));
          return const SizedBox.shrink();
        },
      ),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    expect(bloc.disposeCount, 1);
  });

  testWidgets('ResourceLeaseBuilder scopes leases to mounted resource identity', (tester) async {
    final disposed = <String>[];
    final cache = LruResourceCache<String, String>(
      capacity: 1,
      disposeResource: (key, _) => disposed.add(key),
    );
    var acquireCount = 0;

    Widget buildResource(String identity, String label) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: ResourceLeaseBuilder<String>(
          identity: identity,
          acquire: () {
            acquireCount++;
            return cache.getOrCreateLease(identity, () => identity.toUpperCase());
          },
          builder: (context, value) => Text('$value:$label'),
        ),
      );
    }

    await tester.pumpWidget(buildResource('a', 'first'));
    expect(acquireCount, 1);
    expect(cache.isLeased('a'), isTrue);
    expect(find.text('A:first'), findsOneWidget);

    await tester.pumpWidget(buildResource('a', 'rebuilt'));
    expect(acquireCount, 1);
    expect(find.text('A:rebuilt'), findsOneWidget);

    await tester.pumpWidget(buildResource('b', 'replacement'));
    expect(acquireCount, 2);
    expect(cache.isLeased('a'), isFalse);
    expect(cache.isLeased('b'), isTrue);
    expect(disposed, ['a']);
    expect(find.text('B:replacement'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(cache.isLeased('b'), isFalse);
    cache.dispose();
  });

  testWidgets('DataSubjectBuilder rebuilds when subject changes', (tester) async {
    final subject = DataSubject.seeded('first');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DataSubjectBuilder<String>(subject: subject, builder: (context, data) => Text(data)),
      ),
    );

    expect(find.text('first'), findsOneWidget);

    subject.add('second');
    await tester.pump();

    expect(find.text('second'), findsOneWidget);
  });

  testWidgets('common and sliver layout widgets render their children', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          slivers: [
            SliverGap(8),
            SliverChild(child: Text('single child')),
            SliverColumn(spacing: 4, children: [Text('column child'), Gap(8)]),
            LimitedSliverPadded(
              sliver: SliverToBoxAdapter(
                child: LimitedContainerPadded(child: Text('limited child')),
              ),
            ),
          ],
        ),
      ),
    );

    expect(find.text('single child'), findsOneWidget);
    expect(find.text('column child'), findsOneWidget);
    expect(find.text('limited child'), findsOneWidget);
  });

  testWidgets('ContentLane applies the same width policy to box and sliver content', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 500));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const layout = ContentLayout(maxWidth: 600, gutters: EdgeInsets.symmetric(horizontal: 20));
    const boxKey = Key('box-content');
    const sliverKey = Key('sliver-content');

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            ContentLane.box(
              layout: layout,
              child: SizedBox(key: boxKey, height: 20),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  ContentLane.sliver(
                    layout: layout,
                    sliver: BoxAsSliver(child: SizedBox(key: sliverKey, height: 20)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    expect(tester.getSize(find.byKey(boxKey)).width, 600);
    expect(tester.getSize(find.byKey(sliverKey)).width, 600);
  });

  testWidgets('SliverSequence preserves slivers and inserts main-axis spacing', (tester) async {
    const firstKey = Key('first-sliver');
    const secondKey = Key('second-sliver');

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          slivers: [
            SliverSequence(
              spacing: 12,
              slivers: [
                BoxAsSliver(child: SizedBox(key: firstKey, height: 10)),
                BoxAsSliver(child: SizedBox(key: secondKey, height: 10)),
              ],
            ),
          ],
        ),
      ),
    );

    expect(tester.getTopLeft(find.byKey(secondKey)).dy, 22);
  });

  test('MockKeyValueStore stores and removes values', () async {
    final store = MockKeyValueStore();

    await store.setString('name', 'Hippo');
    await store.setBool('enabled', true);

    expect(await store.getString('name'), 'Hippo');
    expect(await store.getBool('enabled'), isTrue);
    expect(await store.containsKey('name'), isTrue);

    await store.removeValue('name');

    expect(await store.containsKey('name'), isFalse);
  });

  test('SecureKeyValueObjectStoreKeyring persists a generated key', () async {
    final keyValueStore = MockKeyValueStore();
    final keyring = SecureKeyValueObjectStoreKeyring(
      keyValueStore: keyValueStore,
      storeKey: 'object-store-key',
      keyId: 'v1',
    );

    final firstKey = await keyring.currentKey();
    final secondKey = await keyring.currentKey();

    expect(firstKey.id, 'v1');
    expect(secondKey.id, 'v1');
    expect(secondKey.bytes, orderedEquals(firstKey.bytes));
    expect(await keyring.keyForId('unknown'), isNull);
  });

  test('ApplicationSupportObjectStore stores, lists, and deletes files', () async {
    final directory = await Directory.systemTemp.createTemp('hippo-object-store-test-');
    addTearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });
    final store = ApplicationSupportObjectStore(
      namespace: 'test',
      rootDirectoryPath: directory.path,
    );
    final key = ObjectStoreKey(['scope', 'chat.json']);

    await store.writeBytes(key, Uint8List.fromList([1, 2, 3]));

    expect(await store.exists(key), isTrue);
    expect(await store.readBytes(key), [1, 2, 3]);
    expect((await store.list(ObjectStoreKey(['scope']))).map((entry) => entry.key), [key]);

    await store.deleteTree(ObjectStoreKey(['scope']));

    expect(await store.exists(key), isFalse);
  });

  test('FilterController filters data with a text search filter from Flutter', () async {
    final filter = TextSearchResultFilter<String>(
      matchesQuery: (item, query) => item.contains(query),
    );
    final controller = _CoreFilterController<String>(
      items: ['alpha', 'beta', 'gamma'],
      filters: [filter],
    );

    expect(controller.filteredData, ['alpha', 'beta', 'gamma']);

    filter.setQuery('a');
    await Future<void>.delayed(Duration.zero);

    expect(controller.filteredData, ['alpha', 'beta', 'gamma']);

    filter.setQuery('al');
    await Future<void>.delayed(Duration.zero);

    expect(controller.filteredData, ['alpha']);

    controller.setData(['delta', 'alpine']);

    expect(controller.filteredData, ['alpine']);

    controller.dispose();
  });

  test('TextSearchValueFilter exposes typed text query state', () {
    final filter = TextSearchValueFilter('al');

    expect(filter.query, 'al');

    filter.setQuery('be');

    expect(filter.value, 'be');

    filter.clearQuery();

    expect(filter.query, isEmpty);

    filter.dispose();
  });

  test('FilterController supports non-text filters', () {
    final controller = _CoreFilterController<int>(items: [1, 2, 3, 4], filters: [_EvenFilter()]);

    expect(controller.filteredData, [2, 4]);

    controller.setData([5, 6, 7, 8]);

    expect(controller.filteredData, [6, 8]);

    controller.dispose();
  });

  test('FilterController applies multiple filters', () {
    final controller = _CoreFilterController<int>(
      items: [1, 2, 3, 4, 5, 6],
      filters: [_EvenFilter(), _MinimumFilter(4), _MaximumFilter(5)],
    );

    expect(controller.filteredData, [4]);

    controller.dispose();
  });

  test('FilterController updates from a DataSubject source', () async {
    final dataSubject = DataSubject.seeded([1, 2, 3, 4]);
    final controller = _CoreFilterController.fromSubject(
      dataSubject: dataSubject,
      filters: [_EvenFilter()],
    );

    expect(controller.filteredData, [2, 4]);

    dataSubject.add([5, 6, 7, 8]);
    await Future<void>.delayed(Duration.zero);

    expect(controller.filteredData, [6, 8]);

    controller.dispose();
    dataSubject.close();
  });

  test('FilterController fetches items with value filters and applies result filters', () async {
    final searchFilter = TextSearchValueFilter('a');
    var fetchCount = 0;
    final controller = _CoreFilterController.fetched(
      filters: [
        searchFilter,
        TextSearchResultFilter<String>(matchesQuery: (item, query) => item.contains(query)),
      ],
      fetcher: (values) {
        fetchCount++;
        final query = searchFilter.valueFrom(values);
        return ['alpha', 'beta', 'gamma', 'omega'].where((value) => value.contains(query));
      },
    );

    await controller.refresh();

    expect(controller.filteredData, ['alpha', 'beta', 'gamma', 'omega']);

    searchFilter.setQuery('gam');
    await Future<void>.delayed(Duration.zero);

    expect(controller.filteredData, ['gamma']);
    expect(fetchCount, greaterThanOrEqualTo(2));

    controller.dispose();
  });
}

class _CoreFilterController<T> extends FilterController<T> {
  _CoreFilterController({required super.items, super.filters});

  _CoreFilterController.fromSubject({required super.dataSubject, super.filters})
    : super.fromSubject();

  _CoreFilterController.fetched({required super.fetcher, super.filters}) : super.fetched();
}

class _EvenFilter extends ResultFilter<int> {
  @override
  bool matches(int item) {
    return item.isEven;
  }
}

class _MinimumFilter extends ResultFilter<int> {
  const _MinimumFilter(this.minimum);

  final int minimum;

  @override
  bool matches(int item) {
    return item >= minimum;
  }
}

class _MaximumFilter extends ResultFilter<int> {
  const _MaximumFilter(this.maximum);

  final int maximum;

  @override
  bool matches(int item) {
    return item <= maximum;
  }
}
