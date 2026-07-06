import 'package:hippobase_core_models/hippobase_core_models.dart';

import 'query_error.dart';
import 'query_field.dart';

final class QuerySpec {
  QuerySpec({
    required Map<String, QueryField> fields,
    Iterable<SortTerm> defaultSort = const <SortTerm>[],
  }) : fields = Map<String, QueryField>.unmodifiable(fields),
       defaultSort = List<SortTerm>.unmodifiable(defaultSort) {
    if (fields.isEmpty) {
      throw const QueryApplicationException('QuerySpec requires at least one field.');
    }
  }

  final Map<String, QueryField> fields;
  final List<SortTerm> defaultSort;

  QueryField requireField(String field) {
    final queryField = fields[field];
    if (queryField == null) {
      throw QueryApplicationException('Unknown query field "$field".');
    }
    return queryField;
  }

  void requireAllowedOperator(String field, FilterOperator operator) {
    final queryField = requireField(field);
    if (!queryField.allows(operator)) {
      throw QueryApplicationException(
        'Operator "${operator.toJson()}" is not allowed for query field "$field".',
      );
    }
  }
}
