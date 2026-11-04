import 'package:json_schema/json_schema.dart';

part 'stream_lines.g.dart';

const phaseLineSchema = JsonSchema.object(
  id: 'PhaseLine',
  properties: <String, JsonSchema>{
    'type': JsonSchema.string(enumValues: <Object?>['phase']),
    'phase': JsonSchema.string(),
  },
  required: <String>['type', 'phase'],
);

@FromSchema(phaseLineSchema)
typedef PhaseLine = _$PhaseLine;

const keepaliveLineSchema = JsonSchema.object(
  id: 'KeepaliveLine',
  properties: <String, JsonSchema>{
    'type': JsonSchema.string(enumValues: <Object?>['keepalive']),
  },
  required: <String>['type'],
);

@FromSchema(keepaliveLineSchema)
typedef KeepaliveLine = _$KeepaliveLine;

const resultLineSchema = JsonSchema.object(
  id: 'ResultLine',
  properties: <String, JsonSchema>{
    'type': JsonSchema.string(enumValues: <Object?>['result']),
    'data': JsonSchema.object(),
  },
  required: <String>['type', 'data'],
);

@FromSchema(resultLineSchema)
typedef ResultLine = _$ResultLine;

const rolePresentSchema = JsonSchema.object(
  id: 'RolePresent',
  properties: <String, JsonSchema>{
    'configured': JsonSchema.boolean(enumValues: <Object?>[true]),
    'name': JsonSchema.string(),
  },
  required: <String>['configured', 'name'],
);

@FromSchema(rolePresentSchema)
typedef RolePresent = _$RolePresent;

const roleAbsentSchema = JsonSchema.object(
  id: 'RoleAbsent',
  properties: <String, JsonSchema>{
    'configured': JsonSchema.boolean(enumValues: <Object?>[false]),
  },
  required: <String>['configured'],
);

@FromSchema(roleAbsentSchema)
typedef RoleAbsent = _$RoleAbsent;
