// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_lines.dart';

// **************************************************************************
// JsonSchemaBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field, library_private_types_in_public_api, hippo_analysis_plugin/prefer_dot_shorthands
final class _$PhaseLine implements JsonEncodable {
  const _$PhaseLine({required this.type, required this.phase});

  static const schemaId = 'PhaseLine';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'type': JsonSchema.string(enumValues: ['phase']),
      'phase': JsonSchema.string(),
    },
    required: <String>['type', 'phase'],
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  final String type;

  final String phase;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"type": type, "phase": phase};
  }

  static PhaseLine decode(Object? value) {
    return fromJson(value as Map<String, Object?>);
  }

  static PhaseLine fromJson(Map<String, Object?> json) {
    return PhaseLine(type: json["type"]! as String, phase: json["phase"]! as String);
  }
}

final class _$KeepaliveLine implements JsonEncodable {
  const _$KeepaliveLine({required this.type});

  static const schemaId = 'KeepaliveLine';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'type': JsonSchema.string(enumValues: ['keepalive']),
    },
    required: <String>['type'],
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  final String type;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"type": type};
  }

  static KeepaliveLine decode(Object? value) {
    return fromJson(value as Map<String, Object?>);
  }

  static KeepaliveLine fromJson(Map<String, Object?> json) {
    return KeepaliveLine(type: json["type"]! as String);
  }
}

final class _$ResultLine implements JsonEncodable {
  const _$ResultLine({required this.type, required this.data});

  static const schemaId = 'ResultLine';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'type': JsonSchema.string(enumValues: ['result']),
      'data': JsonSchema.object(),
    },
    required: <String>['type', 'data'],
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  final String type;

  final Map<String, Object?> data;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"type": type, "data": data};
  }

  static ResultLine decode(Object? value) {
    return fromJson(value as Map<String, Object?>);
  }

  static ResultLine fromJson(Map<String, Object?> json) {
    return ResultLine(
      type: json["type"]! as String,
      data: Map<String, Object?>.from(json["data"]! as Map),
    );
  }
}

final class _$RolePresent implements JsonEncodable {
  const _$RolePresent({required this.configured, required this.name});

  static const schemaId = 'RolePresent';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'configured': JsonSchema.boolean(enumValues: [true]),
      'name': JsonSchema.string(),
    },
    required: <String>['configured', 'name'],
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  final bool configured;

  final String name;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"configured": configured, "name": name};
  }

  static RolePresent decode(Object? value) {
    return fromJson(value as Map<String, Object?>);
  }

  static RolePresent fromJson(Map<String, Object?> json) {
    return RolePresent(configured: json["configured"]! as bool, name: json["name"]! as String);
  }
}

final class _$RoleAbsent implements JsonEncodable {
  const _$RoleAbsent({required this.configured});

  static const schemaId = 'RoleAbsent';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'configured': JsonSchema.boolean(enumValues: [false]),
    },
    required: <String>['configured'],
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  final bool configured;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"configured": configured};
  }

  static RoleAbsent decode(Object? value) {
    return fromJson(value as Map<String, Object?>);
  }

  static RoleAbsent fromJson(Map<String, Object?> json) {
    return RoleAbsent(configured: json["configured"]! as bool);
  }
}
