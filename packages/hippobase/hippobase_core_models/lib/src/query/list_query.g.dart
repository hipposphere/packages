// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_query.dart';

// **************************************************************************
// JsonSchemaBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$ListQuery implements JsonEncodable {
  const _$ListQuery({this.pagination, this.sort, this.filter});

  static const schemaId = 'ListQuery';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'pagination': JsonSchema.ref('#/components/schemas/PaginationConfig'),
      'sort': JsonSchema.array(items: JsonSchema.ref('#/components/schemas/SortTerm')),
      'filter': JsonSchema.ref('#/components/schemas/FilterGroup'),
    },
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  final PaginationConfig? pagination;

  final List<SortTerm>? sort;

  final FilterGroup? filter;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      "pagination": pagination?.toJson(),
      "sort": sort?.map((item) => item.toJson()).toList(),
      "filter": filter?.toJson(),
    };
  }

  static ListQuery decode(Object? value) {
    return fromJson(value as Map<String, Object?>);
  }

  static ListQuery fromJson(Map<String, Object?> json) {
    return ListQuery(
      pagination: json["pagination"] == null ? null : PaginationConfig.decode(json["pagination"]),
      sort: (json["sort"] as List?)?.map((item) => SortTerm.decode(item)).toList(),
      filter: json["filter"] == null ? null : FilterGroup.decode(json["filter"]),
    );
  }
}
