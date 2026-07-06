// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_group.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$FilterGroup implements JsonEncodable {
  const _$FilterGroup({required this.combinator, required this.filters, this.groups});

  static const schemaId = 'FilterGroup';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'combinator': JsonSchema.ref('#/components/schemas/FilterCombinator'),
      'filters': JsonSchema.array(items: JsonSchema.ref('#/components/schemas/FieldFilter')),
      'groups': JsonSchema.array(
        nullable: true,
        items: JsonSchema.ref('#/components/schemas/FilterGroup'),
      ),
    },
    required: <String>['combinator', 'filters'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final FilterCombinator combinator;

  final List<FieldFilter> filters;

  final List<FilterGroup>? groups;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      "combinator": combinator.toJson(),
      "filters": filters.map((item) => item.toJson()).toList(),
      "groups": groups?.map((item) => item.toJson()).toList(),
    };
  }

  static FilterGroup decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static FilterGroup fromJson(Map<String, Object?> json) {
    return FilterGroup(
      combinator: FilterCombinator.decode(json["combinator"]),
      filters: (json["filters"]! as List).map((item) => FieldFilter.decode(item)).toList(),
      groups: (json["groups"] as List?)?.map((item) => FilterGroup.decode(item)).toList(),
    );
  }
}
