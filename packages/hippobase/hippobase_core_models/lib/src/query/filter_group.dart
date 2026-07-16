import 'package:json_schema/json_schema.dart';

import 'field_filter.dart';
import 'filter_combinator.dart';

part 'filter_group.g.dart';

const filterGroupSchemaId = 'FilterGroup';

/// JSON Schema for [FilterGroup].
const filterGroupSchema = JsonSchema.object(
  id: filterGroupSchemaId,
  properties: <String, JsonSchema>{
    'combinator': JsonSchema.componentRef(filterCombinatorSchemaId),
    'filters': JsonSchema.array(items: JsonSchema.componentRef(fieldFilterSchemaId)),
    'groups': JsonSchema.array(nullable: true, items: JsonSchema.componentRef(filterGroupSchemaId)),
  },
  required: <String>['combinator', 'filters'],
  additionalProperties: false,
);

/// A grouped set of field filters and nested groups.
@FromSchema(filterGroupSchema)
typedef FilterGroup = _$FilterGroup;

extension FilterGroupProperties on FilterGroup {
  List<FilterGroup> get childGroups => groups ?? const <FilterGroup>[];
}

FilterGroup filterGroup({
  required FilterCombinator combinator,
  Iterable<FieldFilter> filters = const <FieldFilter>[],
  Iterable<FilterGroup> groups = const <FilterGroup>[],
}) {
  final filterList = List<FieldFilter>.unmodifiable(filters);
  final groupList = List<FilterGroup>.unmodifiable(groups);

  if (filterList.isEmpty && groupList.isEmpty) {
    throw ArgumentError.value(filters, 'filters', 'must include at least one filter or group');
  }

  return FilterGroup(
    combinator: combinator,
    filters: filterList,
    groups: groupList.isEmpty ? null : groupList,
  );
}

FilterGroup andFilterGroup(
  Iterable<FieldFilter> filters, {
  Iterable<FilterGroup> groups = const <FilterGroup>[],
}) {
  return filterGroup(combinator: FilterCombinator.and, filters: filters, groups: groups);
}

FilterGroup orFilterGroup(
  Iterable<FieldFilter> filters, {
  Iterable<FilterGroup> groups = const <FilterGroup>[],
}) {
  return filterGroup(combinator: FilterCombinator.or, filters: filters, groups: groups);
}
