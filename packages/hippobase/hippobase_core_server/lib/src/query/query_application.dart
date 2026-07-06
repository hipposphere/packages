import 'package:dart_edge_sql/dart_edge_sql.dart';
import 'package:hippobase_core_models/hippobase_core_models.dart';

import 'query_error.dart';
import 'query_field.dart';
import 'query_spec.dart';

extension HippobaseSelectQueryApplication<TRow, TInsert, TUpdate>
    on SelectQueryBuilder<TRow, TInsert, TUpdate> {
  SelectQueryBuilder<TRow, TInsert, TUpdate> applyListQuery(ListQuery query, QuerySpec spec) {
    return applyPagination(
      query.pagination,
    ).applyFilter(query.filter, spec).applySort(query.sort, spec);
  }

  SelectQueryBuilder<TRow, TInsert, TUpdate> applyPagination(PaginationConfig pagination) {
    return offset(pagination.offset).limit(pagination.limit);
  }

  SelectQueryBuilder<TRow, TInsert, TUpdate> applySort(Iterable<SortTerm> sort, QuerySpec spec) {
    var builder = this;
    final effectiveSort = sort.isEmpty ? spec.defaultSort : sort;
    for (final term in effectiveSort) {
      final field = spec.requireField(term.field);
      builder = builder.orderBy(field.column, descending: term.direction == SortDirection.desc);
    }
    return builder;
  }

  SelectQueryBuilder<TRow, TInsert, TUpdate> applyFilter(FilterGroup? filter, QuerySpec spec) {
    if (filter == null) {
      return this;
    }
    return where(filter.toSqlPredicate(spec));
  }
}

extension HippobaseSelectedQueryApplication<TSelection> on SelectedSelectQueryBuilder<TSelection> {
  SelectedSelectQueryBuilder<TSelection> applyListQuery(ListQuery query, QuerySpec spec) {
    return applyPagination(
      query.pagination,
    ).applyFilter(query.filter, spec).applySort(query.sort, spec);
  }

  SelectedSelectQueryBuilder<TSelection> applyPagination(PaginationConfig pagination) {
    return offset(pagination.offset).limit(pagination.limit);
  }

  SelectedSelectQueryBuilder<TSelection> applySort(Iterable<SortTerm> sort, QuerySpec spec) {
    var builder = this;
    final effectiveSort = sort.isEmpty ? spec.defaultSort : sort;
    for (final term in effectiveSort) {
      final field = spec.requireField(term.field);
      builder = builder.orderBy(field.column, descending: term.direction == SortDirection.desc);
    }
    return builder;
  }

  SelectedSelectQueryBuilder<TSelection> applyFilter(FilterGroup? filter, QuerySpec spec) {
    if (filter == null) {
      return this;
    }
    return where(filter.toSqlPredicate(spec));
  }
}

extension HippobaseFilterGroupSql on FilterGroup {
  SqlPredicate toSqlPredicate(QuerySpec spec) {
    final predicates = <SqlPredicate>[
      for (final filter in filters) filter.toSqlPredicate(spec),
      for (final group in childGroups) group.toSqlPredicate(spec),
    ];
    if (predicates.isEmpty) {
      throw const QueryApplicationException('Filter group must contain at least one predicate.');
    }
    return switch (combinator) {
      FilterCombinator.and => SqlPredicate.and(predicates),
      FilterCombinator.or => SqlPredicate.or(predicates),
    };
  }
}

extension HippobaseFieldFilterSql on FieldFilter {
  SqlPredicate toSqlPredicate(QuerySpec spec) {
    spec.requireAllowedOperator(field, operator);
    final queryField = spec.requireField(field);
    return _fieldFilterPredicate(queryField, operator, value);
  }
}

SqlPredicate _fieldFilterPredicate(QueryField field, FilterOperator operator, Object? value) {
  final column = field.column;
  return switch (operator) {
    FilterOperator.eq => value == null ? column.isNull() : column.equals(value),
    FilterOperator.ne => value == null ? column.isNotNull() : column.notEquals(value),
    FilterOperator.lt => column.lessThan(_requireValue(operator, value)),
    FilterOperator.lte => column.lessThanOrEqualTo(_requireValue(operator, value)),
    FilterOperator.gt => column.greaterThan(_requireValue(operator, value)),
    FilterOperator.gte => column.greaterThanOrEqualTo(_requireValue(operator, value)),
    FilterOperator.inList => column.inList(_requireList(operator, value)),
    FilterOperator.notInList => _rawPredicate(column, 'NOT IN', _requireList(operator, value)),
    FilterOperator.between => _betweenPredicate(column, _requireList(operator, value)),
    FilterOperator.isNull => column.isNull(),
    FilterOperator.isNotNull => column.isNotNull(),
    FilterOperator.like => _patternPredicate(field, 'LIKE', _requireString(operator, value)),
    FilterOperator.notLike => _patternPredicate(field, 'NOT LIKE', _requireString(operator, value)),
    FilterOperator.ilike => _patternPredicate(field, 'ILIKE', _requireString(operator, value)),
    FilterOperator.notIlike => _patternPredicate(
      field,
      'NOT ILIKE',
      _requireString(operator, value),
    ),
    FilterOperator.startsWith => _patternPredicate(
      field,
      _patternOperator(field),
      '${_requireString(operator, value)}%',
    ),
    FilterOperator.endsWith => _patternPredicate(
      field,
      _patternOperator(field),
      '%${_requireString(operator, value)}',
    ),
    FilterOperator.contains => _patternPredicate(
      field,
      _patternOperator(field),
      '%${_requireString(operator, value)}%',
    ),
  };
}

SqlPredicate _betweenPredicate(SqlColumn<Object?> column, List<Object?> values) {
  if (values.length != 2) {
    throw const QueryApplicationException('between requires exactly two values.');
  }
  return SqlPredicate.raw(
    '${_columnSql(column)} BETWEEN @lower AND @upper',
    parameters: <String, Object?>{'lower': values[0], 'upper': values[1]},
  );
}

SqlPredicate _rawPredicate(SqlColumn<Object?> column, String operator, List<Object?> values) {
  if (values.isEmpty) {
    throw QueryApplicationException('$operator requires at least one value.');
  }
  final parameters = <String, Object?>{};
  final placeholders = <String>[];
  for (final (index, value) in values.indexed) {
    final name = 'value_$index';
    parameters[name] = value;
    placeholders.add('@$name');
  }
  return SqlPredicate.raw(
    '${_columnSql(column)} $operator (${placeholders.join(', ')})',
    parameters: parameters,
  );
}

SqlPredicate _patternPredicate(QueryField field, String operator, String pattern) {
  if (field.patternMode == QueryFieldPatternMode.disabled) {
    throw const QueryApplicationException('Pattern operators are disabled for this query field.');
  }
  return SqlPredicate.raw(
    '${_columnSql(field.column)} $operator @value',
    parameters: <String, Object?>{'value': pattern},
  );
}

String _columnSql(SqlColumn<Object?> column) {
  return column.qualifiedName.split('.').map(_quoteSqlIdentifier).join('.');
}

String _quoteSqlIdentifier(String identifier) {
  return '"${identifier.replaceAll('"', '""')}"';
}

String _patternOperator(QueryField field) {
  return switch (field.patternMode) {
    QueryFieldPatternMode.disabled => throw const QueryApplicationException(
      'Pattern operators are disabled for this query field.',
    ),
    QueryFieldPatternMode.caseSensitive => 'LIKE',
    QueryFieldPatternMode.caseInsensitive => 'ILIKE',
  };
}

Object _requireValue(FilterOperator operator, Object? value) {
  if (value == null) {
    throw QueryApplicationException('${operator.toJson()} requires a value.');
  }
  return value;
}

String _requireString(FilterOperator operator, Object? value) {
  if (value is! String) {
    throw QueryApplicationException('${operator.toJson()} requires a string value.');
  }
  return value;
}

List<Object?> _requireList(FilterOperator operator, Object? value) {
  if (value is! List) {
    throw QueryApplicationException('${operator.toJson()} requires a list value.');
  }
  return List<Object?>.unmodifiable(value);
}
