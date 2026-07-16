import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:json_schema/json_schema.dart';
import 'user.g.dart';

extension type const AuthSessionId(String value) {
  static const manifest = SqlKeyManifestEntry(
    dartType: 'AuthSessionId',
    baseDartType: 'String',
    schema: 'auth',
    table: 'session',
    column: 'id',
  );

  static const JsonSchema schema = .string(dartType: .value('AuthSessionId'));

  static const JsonSchema schemaNullable = .string(
    nullable: true,
    dartType: .value('AuthSessionId'),
  );
}

final class AuthSessionRow implements JsonEncodable {
  const AuthSessionRow({
    required this.id,
    required this.expiresAt,
    required this.token,
    required this.createdAt,
    required this.updatedAt,
    required this.ipAddress,
    required this.userAgent,
    required this.userId,
    required this.impersonatedBy,
  });

  factory AuthSessionRow.fromSqlRow(SqlRow row, {String prefix = ''}) => AuthSessionRow(
    id: AuthSessionId(row.read<String>('${prefix}id')),
    expiresAt: switch (row.read<Object?>('${prefix}expiresAt')) {
      final DateTime value => value,
      final String value => DateTime.parse(value),
      final value => value as DateTime,
    },
    token: row.read<String>('${prefix}token'),
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
    ipAddress: row.readNullable<String>('${prefix}ipAddress'),
    userAgent: row.readNullable<String>('${prefix}userAgent'),
    userId: AuthUserId(row.read<String>('${prefix}userId')),
    impersonatedBy: row.readNullable<String>('${prefix}impersonatedBy'),
  );

  factory AuthSessionRow.fromColumns(Map<String, Object?> columns, {String prefix = ''}) =>
      AuthSessionRow.fromSqlRow(SqlRow(columns), prefix: prefix);

  factory AuthSessionRow.decode(Object? value) => AuthSessionRow.fromJson(readJsonObject(value));

  factory AuthSessionRow.fromJson(Map<String, Object?> json) => AuthSessionRow(
    id: AuthSessionId((json['id'] as String)),
    expiresAt: DateTime.parse((json['expiresAt'] as String)),
    token: (json['token'] as String),
    createdAt: DateTime.parse((json['createdAt'] as String)),
    updatedAt: DateTime.parse((json['updatedAt'] as String)),
    ipAddress: json['ipAddress'] == null ? null : (json['ipAddress'] as String),
    userAgent: json['userAgent'] == null ? null : (json['userAgent'] as String),
    userId: AuthUserId((json['userId'] as String)),
    impersonatedBy: json['impersonatedBy'] == null ? null : (json['impersonatedBy'] as String),
  );

  static const schemaId = 'AuthSessionRow';

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const jsonSchema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'id': AuthSessionId.schema,
      'expiresAt': JsonSchema.string(format: 'date-time'),
      'token': JsonSchema.string(),
      'createdAt': JsonSchema.string(format: 'date-time'),
      'updatedAt': JsonSchema.string(format: 'date-time'),
      'ipAddress': JsonSchema.string(nullable: true),
      'userAgent': JsonSchema.string(nullable: true),
      'userId': AuthUserId.schema,
      'impersonatedBy': JsonSchema.string(nullable: true),
    },
    required: <String>[
      'id',
      'expiresAt',
      'token',
      'createdAt',
      'updatedAt',
      'ipAddress',
      'userAgent',
      'userId',
      'impersonatedBy',
    ],
    additionalProperties: false,
  );

  final AuthSessionId id;

  final DateTime expiresAt;

  final String token;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String? ipAddress;

  final String? userAgent;

  final AuthUserId userId;

  final String? impersonatedBy;

  AuthSessionRow copyWith({
    AuthSessionId? id,
    DateTime? expiresAt,
    String? token,
    DateTime? createdAt,
    DateTime? updatedAt,
    SqlValue<String?>? ipAddress,
    SqlValue<String?>? userAgent,
    AuthUserId? userId,
    SqlValue<String?>? impersonatedBy,
  }) {
    return AuthSessionRow(
      id: id ?? this.id,
      expiresAt: expiresAt ?? this.expiresAt,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ipAddress: ipAddress == null || !ipAddress.isPresent ? this.ipAddress : ipAddress.value,
      userAgent: userAgent == null || !userAgent.isPresent ? this.userAgent : userAgent.value,
      userId: userId ?? this.userId,
      impersonatedBy: impersonatedBy == null || !impersonatedBy.isPresent
          ? this.impersonatedBy
          : impersonatedBy.value,
    );
  }

  Map<String, Object?> toColumns() => <String, Object?>{
    'id': id.value,
    'expiresAt': expiresAt,
    'token': token,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'ipAddress': ipAddress,
    'userAgent': userAgent,
    'userId': userId.value,
    'impersonatedBy': impersonatedBy,
  };

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'id': id.value,
    'expiresAt': expiresAt.toIso8601String(),
    'token': token,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'ipAddress': ipAddress,
    'userAgent': userAgent,
    'userId': userId.value,
    'impersonatedBy': impersonatedBy,
  };

  @override
  String toString() =>
      'AuthSessionRow(id: $id, expiresAt: $expiresAt, token: $token, createdAt: $createdAt, updatedAt: $updatedAt, ipAddress: $ipAddress, userAgent: $userAgent, userId: $userId, impersonatedBy: $impersonatedBy)';
}

final class AuthSessionInsert implements JsonEncodable {
  const AuthSessionInsert({
    this.id = const SqlValue.absent(),
    required this.expiresAt,
    required this.token,
    required this.createdAt,
    required this.updatedAt,
    required this.ipAddress,
    required this.userAgent,
    required this.userId,
    required this.impersonatedBy,
  });

  factory AuthSessionInsert.decode(Object? value) =>
      AuthSessionInsert.fromJson(readJsonObject(value));

  factory AuthSessionInsert.fromJson(Map<String, Object?> json) => AuthSessionInsert(
    id: json.containsKey('id')
        ? SqlValue<AuthSessionId>(AuthSessionId((json['id'] as String)))
        : const SqlValue.absent(),
    expiresAt: DateTime.parse((json['expiresAt'] as String)),
    token: (json['token'] as String),
    createdAt: DateTime.parse((json['createdAt'] as String)),
    updatedAt: DateTime.parse((json['updatedAt'] as String)),
    ipAddress: json['ipAddress'] == null ? null : (json['ipAddress'] as String),
    userAgent: json['userAgent'] == null ? null : (json['userAgent'] as String),
    userId: AuthUserId((json['userId'] as String)),
    impersonatedBy: json['impersonatedBy'] == null ? null : (json['impersonatedBy'] as String),
  );

  static const schemaId = 'AuthSessionInsert';

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const jsonSchema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'id': AuthSessionId.schema,
      'expiresAt': JsonSchema.string(format: 'date-time'),
      'token': JsonSchema.string(),
      'createdAt': JsonSchema.string(format: 'date-time'),
      'updatedAt': JsonSchema.string(format: 'date-time'),
      'ipAddress': JsonSchema.string(nullable: true),
      'userAgent': JsonSchema.string(nullable: true),
      'userId': AuthUserId.schema,
      'impersonatedBy': JsonSchema.string(nullable: true),
    },
    required: <String>[
      'expiresAt',
      'token',
      'createdAt',
      'updatedAt',
      'ipAddress',
      'userAgent',
      'userId',
      'impersonatedBy',
    ],
    additionalProperties: false,
  );

  final SqlValue<AuthSessionId> id;

  final DateTime expiresAt;

  final String token;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String? ipAddress;

  final String? userAgent;

  final AuthUserId userId;

  final String? impersonatedBy;

  AuthSessionInsert copyWith({
    SqlValue<AuthSessionId>? id,
    DateTime? expiresAt,
    String? token,
    DateTime? createdAt,
    DateTime? updatedAt,
    SqlValue<String?>? ipAddress,
    SqlValue<String?>? userAgent,
    AuthUserId? userId,
    SqlValue<String?>? impersonatedBy,
  }) {
    return AuthSessionInsert(
      id: id ?? this.id,
      expiresAt: expiresAt ?? this.expiresAt,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ipAddress: ipAddress == null || !ipAddress.isPresent ? this.ipAddress : ipAddress.value,
      userAgent: userAgent == null || !userAgent.isPresent ? this.userAgent : userAgent.value,
      userId: userId ?? this.userId,
      impersonatedBy: impersonatedBy == null || !impersonatedBy.isPresent
          ? this.impersonatedBy
          : impersonatedBy.value,
    );
  }

  Map<String, Object?> toColumns() => <String, Object?>{
    if (id.isPresent) 'id': id.value?.value,
    'expiresAt': expiresAt,
    'token': token,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'ipAddress': ipAddress,
    'userAgent': userAgent,
    'userId': userId.value,
    'impersonatedBy': impersonatedBy,
  };

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    if (id.isPresent) 'id': id.value?.value,
    'expiresAt': expiresAt.toIso8601String(),
    'token': token,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'ipAddress': ipAddress,
    'userAgent': userAgent,
    'userId': userId.value,
    'impersonatedBy': impersonatedBy,
  };

  @override
  String toString() =>
      'AuthSessionInsert(id: $id, expiresAt: $expiresAt, token: $token, createdAt: $createdAt, updatedAt: $updatedAt, ipAddress: $ipAddress, userAgent: $userAgent, userId: $userId, impersonatedBy: $impersonatedBy)';
}

final class AuthSessionUpdate implements JsonEncodable {
  const AuthSessionUpdate({
    this.id = const SqlValue.absent(),
    this.expiresAt = const SqlValue.absent(),
    this.token = const SqlValue.absent(),
    this.createdAt = const SqlValue.absent(),
    this.updatedAt = const SqlValue.absent(),
    this.ipAddress = const SqlValue.absent(),
    this.userAgent = const SqlValue.absent(),
    this.userId = const SqlValue.absent(),
    this.impersonatedBy = const SqlValue.absent(),
  });

  factory AuthSessionUpdate.decode(Object? value) =>
      AuthSessionUpdate.fromJson(readJsonObject(value));

  factory AuthSessionUpdate.fromJson(Map<String, Object?> json) => AuthSessionUpdate(
    id: json.containsKey('id')
        ? SqlValue<AuthSessionId>(AuthSessionId((json['id'] as String)))
        : const SqlValue.absent(),
    expiresAt: json.containsKey('expiresAt')
        ? SqlValue<DateTime>(DateTime.parse((json['expiresAt'] as String)))
        : const SqlValue.absent(),
    token: json.containsKey('token')
        ? SqlValue<String>((json['token'] as String))
        : const SqlValue.absent(),
    createdAt: json.containsKey('createdAt')
        ? SqlValue<DateTime>(DateTime.parse((json['createdAt'] as String)))
        : const SqlValue.absent(),
    updatedAt: json.containsKey('updatedAt')
        ? SqlValue<DateTime>(DateTime.parse((json['updatedAt'] as String)))
        : const SqlValue.absent(),
    ipAddress: json.containsKey('ipAddress')
        ? SqlValue<String?>(json['ipAddress'] == null ? null : (json['ipAddress'] as String))
        : const SqlValue.absent(),
    userAgent: json.containsKey('userAgent')
        ? SqlValue<String?>(json['userAgent'] == null ? null : (json['userAgent'] as String))
        : const SqlValue.absent(),
    userId: json.containsKey('userId')
        ? SqlValue<AuthUserId>(AuthUserId((json['userId'] as String)))
        : const SqlValue.absent(),
    impersonatedBy: json.containsKey('impersonatedBy')
        ? SqlValue<String?>(
            json['impersonatedBy'] == null ? null : (json['impersonatedBy'] as String),
          )
        : const SqlValue.absent(),
  );

  static const schemaId = 'AuthSessionUpdate';

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const jsonSchema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'id': AuthSessionId.schema,
      'expiresAt': JsonSchema.string(format: 'date-time'),
      'token': JsonSchema.string(),
      'createdAt': JsonSchema.string(format: 'date-time'),
      'updatedAt': JsonSchema.string(format: 'date-time'),
      'ipAddress': JsonSchema.string(nullable: true),
      'userAgent': JsonSchema.string(nullable: true),
      'userId': AuthUserId.schema,
      'impersonatedBy': JsonSchema.string(nullable: true),
    },
    required: <String>[],
    additionalProperties: false,
  );

  final SqlValue<AuthSessionId> id;

  final SqlValue<DateTime> expiresAt;

  final SqlValue<String> token;

  final SqlValue<DateTime> createdAt;

  final SqlValue<DateTime> updatedAt;

  final SqlValue<String?> ipAddress;

  final SqlValue<String?> userAgent;

  final SqlValue<AuthUserId> userId;

  final SqlValue<String?> impersonatedBy;

  AuthSessionUpdate copyWith({
    SqlValue<AuthSessionId>? id,
    SqlValue<DateTime>? expiresAt,
    SqlValue<String>? token,
    SqlValue<DateTime>? createdAt,
    SqlValue<DateTime>? updatedAt,
    SqlValue<String?>? ipAddress,
    SqlValue<String?>? userAgent,
    SqlValue<AuthUserId>? userId,
    SqlValue<String?>? impersonatedBy,
  }) {
    return AuthSessionUpdate(
      id: id ?? this.id,
      expiresAt: expiresAt ?? this.expiresAt,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      userId: userId ?? this.userId,
      impersonatedBy: impersonatedBy ?? this.impersonatedBy,
    );
  }

  Map<String, Object?> toColumns() => <String, Object?>{
    if (id.isPresent) 'id': id.value?.value,
    if (expiresAt.isPresent) 'expiresAt': expiresAt.value,
    if (token.isPresent) 'token': token.value,
    if (createdAt.isPresent) 'createdAt': createdAt.value,
    if (updatedAt.isPresent) 'updatedAt': updatedAt.value,
    if (ipAddress.isPresent) 'ipAddress': ipAddress.value,
    if (userAgent.isPresent) 'userAgent': userAgent.value,
    if (userId.isPresent) 'userId': userId.value?.value,
    if (impersonatedBy.isPresent) 'impersonatedBy': impersonatedBy.value,
  };

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    if (id.isPresent) 'id': id.value?.value,
    if (expiresAt.isPresent) 'expiresAt': expiresAt.value?.toIso8601String(),
    if (token.isPresent) 'token': token.value,
    if (createdAt.isPresent) 'createdAt': createdAt.value?.toIso8601String(),
    if (updatedAt.isPresent) 'updatedAt': updatedAt.value?.toIso8601String(),
    if (ipAddress.isPresent) 'ipAddress': ipAddress.value,
    if (userAgent.isPresent) 'userAgent': userAgent.value,
    if (userId.isPresent) 'userId': userId.value?.value,
    if (impersonatedBy.isPresent) 'impersonatedBy': impersonatedBy.value,
  };

  @override
  String toString() =>
      'AuthSessionUpdate(id: $id, expiresAt: $expiresAt, token: $token, createdAt: $createdAt, updatedAt: $updatedAt, ipAddress: $ipAddress, userAgent: $userAgent, userId: $userId, impersonatedBy: $impersonatedBy)';
}

final class AuthSessionsTable
    extends SqlTable<AuthSessionRow, AuthSessionInsert, AuthSessionUpdate> {
  const AuthSessionsTable._() : schema = 'auth';

  const AuthSessionsTable.withSchema(this.schema);

  @override
  final String? schema;

  @override
  String get selectionPrefix => '${name}__';

  static const table = AuthSessionsTable._();

  static const id = SqlColumn<AuthSessionId>(
    table: AuthSessionsTable.withSchema(null),
    name: 'id',
    nullable: false,
    databaseType: 'text',
  );

  static const expiresAt = SqlColumn<DateTime>(
    table: AuthSessionsTable.withSchema(null),
    name: 'expiresAt',
    nullable: false,
    databaseType: 'timestamptz',
  );

  static const token = SqlColumn<String>(
    table: AuthSessionsTable.withSchema(null),
    name: 'token',
    nullable: false,
    databaseType: 'text',
  );

  static const createdAt = SqlColumn<DateTime>(
    table: AuthSessionsTable.withSchema(null),
    name: 'createdAt',
    nullable: false,
    databaseType: 'timestamptz',
  );

  static const updatedAt = SqlColumn<DateTime>(
    table: AuthSessionsTable.withSchema(null),
    name: 'updatedAt',
    nullable: false,
    databaseType: 'timestamptz',
  );

  static const ipAddress = SqlColumn<String>(
    table: AuthSessionsTable.withSchema(null),
    name: 'ipAddress',
    nullable: true,
    databaseType: 'text',
  );

  static const userAgent = SqlColumn<String>(
    table: AuthSessionsTable.withSchema(null),
    name: 'userAgent',
    nullable: true,
    databaseType: 'text',
  );

  static const userId = SqlColumn<AuthUserId>(
    table: AuthSessionsTable.withSchema(null),
    name: 'userId',
    nullable: false,
    databaseType: 'text',
  );

  static const impersonatedBy = SqlColumn<String>(
    table: AuthSessionsTable.withSchema(null),
    name: 'impersonatedBy',
    nullable: true,
    databaseType: 'text',
  );

  @override
  String get name => 'session';

  @override
  List<SqlColumnBase> get columns => <SqlColumnBase>[
    id,
    expiresAt,
    token,
    createdAt,
    updatedAt,
    ipAddress,
    userAgent,
    userId,
    impersonatedBy,
  ];

  @override
  AuthSessionRow mapRow(SqlRow row, {String prefix = ''}) =>
      AuthSessionRow.fromSqlRow(row, prefix: prefix);

  @override
  Map<String, Object?> encodeInsert(AuthSessionInsert value) => value.toColumns();

  @override
  Map<String, Object?> encodeUpdate(AuthSessionUpdate value) => value.toColumns();
}
