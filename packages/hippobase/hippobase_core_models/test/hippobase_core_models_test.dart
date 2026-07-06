import 'package:hippobase_core_models/hippobase_core_models.dart';
import 'package:test/test.dart';

void main() {
  group('PaginationConfig', () {
    test('uses offset-based configuration', () {
      final config = paginationConfig(offset: 50, limit: 25);

      expect(config.offset, 50);
      expect(config.limit, 25);
      expect(config.toJson(), <String, Object?>{'offset': 50, 'limit': 25});
      expect(PaginationConfig.schema.id, paginationConfigSchemaId);
    });

    test('validates offset and limit helper values', () {
      expect(() => paginationConfig(offset: -1), throwsArgumentError);
      expect(() => paginationConfig(limit: 0), throwsArgumentError);
    });
  });

  group('PaginationMeta', () {
    test('derives offset pagination metadata', () {
      final meta = paginationMetaFromConfig(
        config: paginationConfig(offset: 10, limit: 10),
        totalItems: 25,
      );

      expect(meta.offset, 10);
      expect(meta.limit, 10);
      expect(meta.totalItems, 25);
      expect(meta.hasMore, isTrue);
      expect(meta.nextOffset, 20);
      expect(meta.previousOffset, 0);
      expect(meta.firstItemIndex, 11);
      expect(meta.lastItemIndex, 20);
      expect(meta.toJson(), containsPair('total_items', 25));
      expect(meta.toJson(), containsPair('has_more', isTrue));
      expect(meta.toJson(), containsPair('next_offset', 20));
      expect(PaginationMeta.schema.id, paginationMetaSchemaId);
    });
  });

  group('ListQuery', () {
    test('round-trips nested filters and sort terms through JSON', () {
      final query = ListQuery(
        pagination: paginationConfig(offset: 0, limit: 20),
        sort: [SortTerm(field: 'createdAt', direction: SortDirection.desc)],
        filter: andFilterGroup(
          [fieldFilter('status', FilterOperator.eq, 'active')],
          groups: [
            orFilterGroup([
              fieldFilter('age', FilterOperator.gte, 18),
              fieldFilter('email', FilterOperator.ilike, '%@hippolabs.org'),
            ]),
          ],
        ),
      );

      final json = query.toJson();
      final parsed = ListQuery.fromJson(json);

      expect(parsed.pagination.offset, 0);
      expect(parsed.pagination.limit, 20);
      expect(parsed.sort.single.field, 'createdAt');
      expect(parsed.sort.single.direction, SortDirection.desc);
      expect(parsed.filter?.combinator, FilterCombinator.and);
      expect(parsed.filter?.filters.single.operator, FilterOperator.eq);
      expect(parsed.filter?.childGroups.single.combinator, FilterCombinator.or);
      expect(parsed.toJson(), json);
    });

    test('round-trips field filters through JSON', () {
      final filter = fieldFilter('status', FilterOperator.eq, 'active');

      final parsed = FieldFilter.fromJson(filter.toJson());

      expect(parsed.field, 'status');
      expect(parsed.operator, FilterOperator.eq);
      expect(parsed.value, 'active');
      expect(parsed.toJson(), <String, Object?>{
        'field': 'status',
        'operator': 'eq',
        'value': 'active',
      });
    });

    test('round-trips filter groups through JSON', () {
      final group = andFilterGroup(
        [fieldFilter('status', FilterOperator.eq, 'active')],
        groups: [
          orFilterGroup([fieldFilter('age', FilterOperator.gte, 18)]),
        ],
      );

      final parsed = FilterGroup.fromJson(group.toJson());

      expect(parsed.combinator, FilterCombinator.and);
      expect(parsed.filters.single.field, 'status');
      expect(parsed.childGroups.single.filters.single.field, 'age');
      expect(parsed.toJson(), group.toJson());
    });

    test('parses symbolic comparison operator aliases', () {
      final operator = filterOperatorFromJson('>=');

      expect(operator, FilterOperator.gte);
    });

    test('uses snake case operator JSON values', () {
      final operator = filterOperatorFromJson('not_like');

      expect(operator, FilterOperator.notLike);
      expect(operator.toJson(), 'not_like');
      expect(FilterOperator.startsWith.toJson(), 'starts_with');
      expect(FilterOperator.inList.toJson(), 'in_list');
      expect(FilterOperator.isNotNull.toJson(), 'is_not_null');
    });

    test('validates operator value shapes', () {
      expect(
        () => fieldFilter('email', FilterOperator.ilike, <String>['wrong']),
        throwsArgumentError,
      );
      expect(
        () => fieldFilter('createdAt', FilterOperator.between, ['2026-01-01']),
        throwsArgumentError,
      );
      expect(() => fieldFilter('deletedAt', FilterOperator.isNull, true), throwsArgumentError);
    });
  });

  group('PaginatedResponse', () {
    test('round-trips item JSON with pagination metadata', () {
      final response = PaginatedResponse(
        items: [
          <String, Object?>{'id': 'one'},
          <String, Object?>{'id': 'two'},
        ],
        meta: paginationMetaFromConfig(
          config: paginationConfig(offset: 0, limit: 2),
          totalItems: 5,
        ),
      );

      final json = response.toJson();
      final parsed = PaginatedResponse.fromJson(json);

      expect(parsed.items, [
        <String, Object?>{'id': 'one'},
        <String, Object?>{'id': 'two'},
      ]);
      expect(parsed.meta.hasMore, isTrue);
      expect(parsed.meta.nextOffset, 2);
      expect(parsed.toJson(), json);
    });
  });

  group('schemas', () {
    test('exports core model schemas for project registries', () {
      expect(
        hippobaseCoreModelsSchemas.map((schema) => schema.id),
        containsAll(<String>[
          paginationConfigSchemaId,
          paginationMetaSchemaId,
          paginatedResponseSchemaId,
          filterOperatorSchemaId,
          filterCombinatorSchemaId,
          fieldFilterSchemaId,
          filterGroupSchemaId,
          listQuerySchemaId,
        ]),
      );
    });
  });
}
