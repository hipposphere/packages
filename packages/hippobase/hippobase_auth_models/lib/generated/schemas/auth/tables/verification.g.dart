import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:json_schema/json_schema.dart';

extension type const AuthVerificationId(String value) {
  static const manifest = SqlKeyManifestEntry(
    dartType: 'AuthVerificationId',
    baseDartType: 'String',
    schema: 'auth',
    table: 'verification',
    column: 'id',
  );

  static const JsonSchema schema = .string(dartType: .value('AuthVerificationId'));

  static const JsonSchema schemaNullable = .string(
    nullable: true,
    dartType: .value('AuthVerificationId'),
  );
}

final class AuthVerificationRow implements JsonEncodable {
  const AuthVerificationRow({
    required this.id,
    required this.identifier,
    required this.value,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuthVerificationRow.fromSqlRow(SqlRow row, {String prefix = ''}) => AuthVerificationRow(
    id: AuthVerificationId(row.read<String>('${prefix}id')),
    identifier: row.read<String>('${prefix}identifier'),
    value: row.read<String>('${prefix}value'),
    expiresAt: switch (row.read<Object?>('${prefix}expiresAt')) {
      final DateTime value => value,
      final String value => DateTime.parse(value),
      final value => value as DateTime,
    },
    createdAt: switch (row.read<Object?>('${prefix}createdAt')) {
      final DateTime value => value,
      final String value => DateTime.parse(value),
      final value => value as DateTime,
    },
    updatedAt: switch (row.read<Object?>('${prefix}updatedAt')) {
      final DateTime value => value,
      final String value => DateTime.parse(value),
      final value => value as DateTime,
    },
  );

  factory AuthVerificationRow.fromColumns(Map<String, Object?> columns, {String prefix = ''}) =>
      AuthVerificationRow.fromSqlRow(SqlRow(columns), prefix: prefix);

  factory AuthVerificationRow.decode(Object? value) =>
      AuthVerificationRow.fromJson(readJsonObject(value));

  factory AuthVerificationRow.fromJson(Map<String, Object?> json) => AuthVerificationRow(
    id: AuthVerificationId((json['id'] as String)),
    identifier: (json['identifier'] as String),
    value: (json['value'] as String),
    expiresAt: DateTime.parse((json['expiresAt'] as String)),
    createdAt: DateTime.parse((json['createdAt'] as String)),
    updatedAt: DateTime.parse((json['updatedAt'] as String)),
  );

  static const schemaId = 'AuthVerificationRow';

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const jsonSchema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'id': AuthVerificationId.schema,
      'identifier': JsonSchema.string(),
      'value': JsonSchema.string(),
      'expiresAt': JsonSchema.string(format: 'date-time'),
      'createdAt': JsonSchema.string(format: 'date-time'),
      'updatedAt': JsonSchema.string(format: 'date-time'),
    },
    required: <String>['id', 'identifier', 'value', 'expiresAt', 'createdAt', 'updatedAt'],
    additionalProperties: false,
  );

  final AuthVerificationId id;

  final String identifier;

  final String value;

  final DateTime expiresAt;

  final DateTime createdAt;

  final DateTime updatedAt;

  AuthVerificationRow copyWith({
    AuthVerificationId? id,
    String? identifier,
    String? value,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthVerificationRow(
      id: id ?? this.id,
      identifier: identifier ?? this.identifier,
      value: value ?? this.value,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toColumns() => <String, Object?>{
    'id': id.value,
    'identifier': identifier,
    'value': value,
    'expiresAt': expiresAt,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'id': id.value,
    'identifier': identifier,
    'value': value,
    'expiresAt': expiresAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  String toString() =>
      'AuthVerificationRow(id: $id, identifier: $identifier, value: $value, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}

final class AuthVerificationInsert implements JsonEncodable {
  const AuthVerificationInsert({
    this.id = const SqlValue.absent(),
    required this.identifier,
    required this.value,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuthVerificationInsert.decode(Object? value) =>
      AuthVerificationInsert.fromJson(readJsonObject(value));

  factory AuthVerificationInsert.fromJson(Map<String, Object?> json) => AuthVerificationInsert(
    id: json.containsKey('id')
        ? SqlValue<AuthVerificationId>(AuthVerificationId((json['id'] as String)))
        : const SqlValue.absent(),
    identifier: (json['identifier'] as String),
    value: (json['value'] as String),
    expiresAt: DateTime.parse((json['expiresAt'] as String)),
    createdAt: DateTime.parse((json['createdAt'] as String)),
    updatedAt: DateTime.parse((json['updatedAt'] as String)),
  );

  static const schemaId = 'AuthVerificationInsert';

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const jsonSchema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'id': AuthVerificationId.schema,
      'identifier': JsonSchema.string(),
      'value': JsonSchema.string(),
      'expiresAt': JsonSchema.string(format: 'date-time'),
      'createdAt': JsonSchema.string(format: 'date-time'),
      'updatedAt': JsonSchema.string(format: 'date-time'),
    },
    required: <String>['identifier', 'value', 'expiresAt', 'createdAt', 'updatedAt'],
    additionalProperties: false,
  );

  final SqlValue<AuthVerificationId> id;

  final String identifier;

  final String value;

  final DateTime expiresAt;

  final DateTime createdAt;

  final DateTime updatedAt;

  AuthVerificationInsert copyWith({
    SqlValue<AuthVerificationId>? id,
    String? identifier,
    String? value,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthVerificationInsert(
      id: id ?? this.id,
      identifier: identifier ?? this.identifier,
      value: value ?? this.value,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toColumns() => <String, Object?>{
    if (id.isPresent) 'id': id.value?.value,
    'identifier': identifier,
    'value': value,
    'expiresAt': expiresAt,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    if (id.isPresent) 'id': id.value?.value,
    'identifier': identifier,
    'value': value,
    'expiresAt': expiresAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  String toString() =>
      'AuthVerificationInsert(id: $id, identifier: $identifier, value: $value, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}

final class AuthVerificationUpdate implements JsonEncodable {
  const AuthVerificationUpdate({
    this.id = const SqlValue.absent(),
    this.identifier = const SqlValue.absent(),
    this.value = const SqlValue.absent(),
    this.expiresAt = const SqlValue.absent(),
    this.createdAt = const SqlValue.absent(),
    this.updatedAt = const SqlValue.absent(),
  });

  factory AuthVerificationUpdate.decode(Object? value) =>
      AuthVerificationUpdate.fromJson(readJsonObject(value));

  factory AuthVerificationUpdate.fromJson(Map<String, Object?> json) => AuthVerificationUpdate(
    id: json.containsKey('id')
        ? SqlValue<AuthVerificationId>(AuthVerificationId((json['id'] as String)))
        : const SqlValue.absent(),
    identifier: json.containsKey('identifier')
        ? SqlValue<String>((json['identifier'] as String))
        : const SqlValue.absent(),
    value: json.containsKey('value')
        ? SqlValue<String>((json['value'] as String))
        : const SqlValue.absent(),
    expiresAt: json.containsKey('expiresAt')
        ? SqlValue<DateTime>(DateTime.parse((json['expiresAt'] as String)))
        : const SqlValue.absent(),
    createdAt: json.containsKey('createdAt')
        ? SqlValue<DateTime>(DateTime.parse((json['createdAt'] as String)))
        : const SqlValue.absent(),
    updatedAt: json.containsKey('updatedAt')
        ? SqlValue<DateTime>(DateTime.parse((json['updatedAt'] as String)))
        : const SqlValue.absent(),
  );

  static const schemaId = 'AuthVerificationUpdate';

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const jsonSchema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'id': AuthVerificationId.schema,
      'identifier': JsonSchema.string(),
      'value': JsonSchema.string(),
      'expiresAt': JsonSchema.string(format: 'date-time'),
      'createdAt': JsonSchema.string(format: 'date-time'),
      'updatedAt': JsonSchema.string(format: 'date-time'),
    },
    required: <String>[],
    additionalProperties: false,
  );

  final SqlValue<AuthVerificationId> id;

  final SqlValue<String> identifier;

  final SqlValue<String> value;

  final SqlValue<DateTime> expiresAt;

  final SqlValue<DateTime> createdAt;

  final SqlValue<DateTime> updatedAt;

  AuthVerificationUpdate copyWith({
    SqlValue<AuthVerificationId>? id,
    SqlValue<String>? identifier,
    SqlValue<String>? value,
    SqlValue<DateTime>? expiresAt,
    SqlValue<DateTime>? createdAt,
    SqlValue<DateTime>? updatedAt,
  }) {
    return AuthVerificationUpdate(
      id: id ?? this.id,
      identifier: identifier ?? this.identifier,
      value: value ?? this.value,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toColumns() => <String, Object?>{
    if (id.isPresent) 'id': id.value?.value,
    if (identifier.isPresent) 'identifier': identifier.value,
    if (value.isPresent) 'value': value.value,
    if (expiresAt.isPresent) 'expiresAt': expiresAt.value,
    if (createdAt.isPresent) 'createdAt': createdAt.value,
    if (updatedAt.isPresent) 'updatedAt': updatedAt.value,
  };

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    if (id.isPresent) 'id': id.value?.value,
    if (identifier.isPresent) 'identifier': identifier.value,
    if (value.isPresent) 'value': value.value,
    if (expiresAt.isPresent) 'expiresAt': expiresAt.value?.toIso8601String(),
    if (createdAt.isPresent) 'createdAt': createdAt.value?.toIso8601String(),
    if (updatedAt.isPresent) 'updatedAt': updatedAt.value?.toIso8601String(),
  };

  @override
  String toString() =>
      'AuthVerificationUpdate(id: $id, identifier: $identifier, value: $value, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}

final class AuthVerificationsTable
    extends SqlTable<AuthVerificationRow, AuthVerificationInsert, AuthVerificationUpdate> {
  const AuthVerificationsTable._() : schema = 'auth';

  const AuthVerificationsTable.withSchema(this.schema);

  @override
  final String? schema;

  @override
  String get selectionPrefix => '${name}__';

  static const table = AuthVerificationsTable._();

  static const id = SqlColumn<AuthVerificationId>(
    table: AuthVerificationsTable.withSchema(null),
    name: 'id',
    nullable: false,
    databaseType: 'text',
  );

  static const identifier = SqlColumn<String>(
    table: AuthVerificationsTable.withSchema(null),
    name: 'identifier',
    nullable: false,
    databaseType: 'text',
  );

  static const value = SqlColumn<String>(
    table: AuthVerificationsTable.withSchema(null),
    name: 'value',
    nullable: false,
    databaseType: 'text',
  );

  static const expiresAt = SqlColumn<DateTime>(
    table: AuthVerificationsTable.withSchema(null),
    name: 'expiresAt',
    nullable: false,
    databaseType: 'timestamptz',
  );

  static const createdAt = SqlColumn<DateTime>(
    table: AuthVerificationsTable.withSchema(null),
    name: 'createdAt',
    nullable: false,
    databaseType: 'timestamptz',
  );

  static const updatedAt = SqlColumn<DateTime>(
    table: AuthVerificationsTable.withSchema(null),
    name: 'updatedAt',
    nullable: false,
    databaseType: 'timestamptz',
  );

  @override
  String get name => 'verification';

  @override
  List<SqlColumnBase> get columns => <SqlColumnBase>[
    id,
    identifier,
    value,
    expiresAt,
    createdAt,
    updatedAt,
  ];

  @override
  AuthVerificationRow mapRow(SqlRow row, {String prefix = ''}) =>
      AuthVerificationRow.fromSqlRow(row, prefix: prefix);

  @override
  Map<String, Object?> encodeInsert(AuthVerificationInsert value) => value.toColumns();

  @override
  Map<String, Object?> encodeUpdate(AuthVerificationUpdate value) => value.toColumns();
}
