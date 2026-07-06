// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_query.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$ListQuery implements JsonEncodable {
  const _$ListQuery({required this.pagination, required this.sort, this.filter});

  static const schemaId = 'ListQuery';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'pagination': JsonSchema.ref('#/components/schemas/PaginationConfig'),
      'sort': JsonSchema.array(items: JsonSchema.ref('#/components/schemas/SortTerm')),
      'filter': JsonSchema.ref('#/components/schemas/FilterGroup'),
    },
    required: <String>['pagination', 'sort'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final PaginationConfig pagination;

  final List<SortTerm> sort;

  final FilterGroup? filter;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      "pagination": pagination.toJson(),
      "sort": sort.map((item) => item.toJson()).toList(),
      "filter": filter?.toJson(),
    };
  }

  static ListQuery decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static ListQuery fromJson(Map<String, Object?> json) {
    return ListQuery(
      pagination: PaginationConfig.decode(json["pagination"]),
      sort: (json["sort"]! as List).map((item) => SortTerm.decode(item)).toList(),
      filter: json["filter"] == null ? null : FilterGroup.decode(json["filter"]),
    );
  }
}
