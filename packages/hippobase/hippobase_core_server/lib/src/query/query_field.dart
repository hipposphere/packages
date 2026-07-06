import 'package:dart_edge_sql/dart_edge_sql.dart';
import 'package:hippobase_core_models/hippobase_core_models.dart';

final class QueryField {
  const QueryField({
    required this.column,
    this.allowedOperators,
    this.patternMode = QueryFieldPatternMode.disabled,
  });

  factory QueryField.value(SqlColumn<Object?> column, {Set<FilterOperator>? allowedOperators}) {
    return QueryField(column: column, allowedOperators: allowedOperators);
  }

  factory QueryField.text(
    SqlColumn<String> column, {
    Set<FilterOperator>? allowedOperators,
    QueryFieldPatternMode patternMode = QueryFieldPatternMode.caseSensitive,
  }) {
    return QueryField(
      column: column.asObjectColumn,
      allowedOperators: allowedOperators,
      patternMode: patternMode,
    );
  }

  factory QueryField.number(SqlColumn<num> column, {Set<FilterOperator>? allowedOperators}) {
    return QueryField(column: column.asObjectColumn, allowedOperators: allowedOperators);
  }

  factory QueryField.integer(SqlColumn<int> column, {Set<FilterOperator>? allowedOperators}) {
    return QueryField(column: column.asObjectColumn, allowedOperators: allowedOperators);
  }

  factory QueryField.boolean(SqlColumn<bool> column, {Set<FilterOperator>? allowedOperators}) {
    return QueryField(column: column.asObjectColumn, allowedOperators: allowedOperators);
  }

  factory QueryField.dateTime(SqlColumn<DateTime> column, {Set<FilterOperator>? allowedOperators}) {
    return QueryField(column: column.asObjectColumn, allowedOperators: allowedOperators);
  }

  final SqlColumn<Object?> column;
  final Set<FilterOperator>? allowedOperators;
  final QueryFieldPatternMode patternMode;

  bool allows(FilterOperator operator) {
    return allowedOperators == null || allowedOperators!.contains(operator);
  }
}

enum QueryFieldPatternMode { disabled, caseSensitive, caseInsensitive }
