import 'package:dart_edge_core/dart_edge_core.dart';
import 'user.g.dart';

extension type const AuthAccountId(String value) {
  static const manifest = SqlKeyManifestEntry(
    dartType: 'AuthAccountId',
    baseDartType: 'String',
    schema: 'auth',
    table: 'account',
    column: 'id',
  );

  static const JsonSchema schema = .string(dartType: .value('AuthAccountId'));

  static const JsonSchema schemaNullable = .string(
    nullable: true,
    dartType: .value('AuthAccountId'),
  );
}

final class AuthAccountRow implements JsonEncodable {
  const AuthAccountRow({
    required this.id,
    required this.accountId,
    required this.providerId,
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.idToken,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
    required this.scope,
    required this.password,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuthAccountRow.fromSqlRow(SqlRow row, {String prefix = ''}) => AuthAccountRow(
    id: AuthAccountId(row.read<String>('${prefix}id')),
    accountId: row.read<String>('${prefix}accountId'),
    providerId: row.read<String>('${prefix}providerId'),
    userId: AuthUserId(row.read<String>('${prefix}userId')),
    accessToken: row.readNullable<String>('${prefix}accessToken'),
    refreshToken: row.readNullable<String>('${prefix}refreshToken'),
    idToken: row.readNullable<String>('${prefix}idToken'),
    accessTokenExpiresAt: switch (row.readNullable<Object?>('${prefix}accessTokenExpiresAt')) {
      null => null,
      final DateTime value => value,
      final String value => DateTime.parse(value),
      final value => value as DateTime,
    },
    refreshTokenExpiresAt: switch (row.readNullable<Object?>('${prefix}refreshTokenExpiresAt')) {
      null => null,
      final DateTime value => value,
      final String value => DateTime.parse(value),
      final value => value as DateTime,
    },
    scope: row.readNullable<String>('${prefix}scope'),
    password: row.readNullable<String>('${prefix}password'),
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

  factory AuthAccountRow.fromColumns(Map<String, Object?> columns, {String prefix = ''}) =>
      AuthAccountRow.fromSqlRow(SqlRow(columns), prefix: prefix);

  factory AuthAccountRow.decode(Object? value) => AuthAccountRow.fromJson(readJsonObject(value));

  factory AuthAccountRow.fromJson(Map<String, Object?> json) => AuthAccountRow(
    id: AuthAccountId((json['id'] as String)),
    accountId: (json['accountId'] as String),
    providerId: (json['providerId'] as String),
    userId: AuthUserId((json['userId'] as String)),
    accessToken: json['accessToken'] == null ? null : (json['accessToken'] as String),
    refreshToken: json['refreshToken'] == null ? null : (json['refreshToken'] as String),
    idToken: json['idToken'] == null ? null : (json['idToken'] as String),
    accessTokenExpiresAt: json['accessTokenExpiresAt'] == null
        ? null
        : DateTime.parse((json['accessTokenExpiresAt'] as String)),
    refreshTokenExpiresAt: json['refreshTokenExpiresAt'] == null
        ? null
        : DateTime.parse((json['refreshTokenExpiresAt'] as String)),
    scope: json['scope'] == null ? null : (json['scope'] as String),
    password: json['password'] == null ? null : (json['password'] as String),
    createdAt: DateTime.parse((json['createdAt'] as String)),
    updatedAt: DateTime.parse((json['updatedAt'] as String)),
  );

  static const schemaId = 'AuthAccountRow';

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const jsonSchema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'id': AuthAccountId.schema,
      'accountId': JsonSchema.string(),
      'providerId': JsonSchema.string(),
      'userId': AuthUserId.schema,
      'accessToken': JsonSchema.string(nullable: true),
      'refreshToken': JsonSchema.string(nullable: true),
      'idToken': JsonSchema.string(nullable: true),
      'accessTokenExpiresAt': JsonSchema.string(nullable: true, format: 'date-time'),
      'refreshTokenExpiresAt': JsonSchema.string(nullable: true, format: 'date-time'),
      'scope': JsonSchema.string(nullable: true),
      'password': JsonSchema.string(nullable: true),
      'createdAt': JsonSchema.string(format: 'date-time'),
      'updatedAt': JsonSchema.string(format: 'date-time'),
    },
    required: <String>[
      'id',
      'accountId',
      'providerId',
      'userId',
      'accessToken',
      'refreshToken',
      'idToken',
      'accessTokenExpiresAt',
      'refreshTokenExpiresAt',
      'scope',
      'password',
      'createdAt',
      'updatedAt',
    ],
    additionalProperties: false,
  );

  final AuthAccountId id;

  final String accountId;

  final String providerId;

  final AuthUserId userId;

  final String? accessToken;

  final String? refreshToken;

  final String? idToken;

  final DateTime? accessTokenExpiresAt;

  final DateTime? refreshTokenExpiresAt;

  final String? scope;

  final String? password;

  final DateTime createdAt;

  final DateTime updatedAt;

  AuthAccountRow copyWith({
    AuthAccountId? id,
    String? accountId,
    String? providerId,
    AuthUserId? userId,
    SqlValue<String?>? accessToken,
    SqlValue<String?>? refreshToken,
    SqlValue<String?>? idToken,
    SqlValue<DateTime?>? accessTokenExpiresAt,
    SqlValue<DateTime?>? refreshTokenExpiresAt,
    SqlValue<String?>? scope,
    SqlValue<String?>? password,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthAccountRow(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      providerId: providerId ?? this.providerId,
      userId: userId ?? this.userId,
      accessToken: accessToken == null || !accessToken.isPresent
          ? this.accessToken
          : accessToken.value,
      refreshToken: refreshToken == null || !refreshToken.isPresent
          ? this.refreshToken
          : refreshToken.value,
      idToken: idToken == null || !idToken.isPresent ? this.idToken : idToken.value,
      accessTokenExpiresAt: accessTokenExpiresAt == null || !accessTokenExpiresAt.isPresent
          ? this.accessTokenExpiresAt
          : accessTokenExpiresAt.value,
      refreshTokenExpiresAt: refreshTokenExpiresAt == null || !refreshTokenExpiresAt.isPresent
          ? this.refreshTokenExpiresAt
          : refreshTokenExpiresAt.value,
      scope: scope == null || !scope.isPresent ? this.scope : scope.value,
      password: password == null || !password.isPresent ? this.password : password.value,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toColumns() => <String, Object?>{
    'id': id.value,
    'accountId': accountId,
    'providerId': providerId,
    'userId': userId.value,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'idToken': idToken,
    'accessTokenExpiresAt': accessTokenExpiresAt,
    'refreshTokenExpiresAt': refreshTokenExpiresAt,
    'scope': scope,
    'password': password,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'id': id.value,
    'accountId': accountId,
    'providerId': providerId,
    'userId': userId.value,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'idToken': idToken,
    'accessTokenExpiresAt': accessTokenExpiresAt?.toIso8601String(),
    'refreshTokenExpiresAt': refreshTokenExpiresAt?.toIso8601String(),
    'scope': scope,
    'password': password,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  String toString() =>
      'AuthAccountRow(id: $id, accountId: $accountId, providerId: $providerId, userId: $userId, accessToken: $accessToken, refreshToken: $refreshToken, idToken: $idToken, accessTokenExpiresAt: $accessTokenExpiresAt, refreshTokenExpiresAt: $refreshTokenExpiresAt, scope: $scope, password: $password, createdAt: $createdAt, updatedAt: $updatedAt)';
}

final class AuthAccountInsert implements JsonEncodable {
  const AuthAccountInsert({
    this.id = const SqlValue.absent(),
    required this.accountId,
    required this.providerId,
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.idToken,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
    required this.scope,
    required this.password,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuthAccountInsert.decode(Object? value) =>
      AuthAccountInsert.fromJson(readJsonObject(value));

  factory AuthAccountInsert.fromJson(Map<String, Object?> json) => AuthAccountInsert(
    id: json.containsKey('id')
        ? SqlValue<AuthAccountId>(AuthAccountId((json['id'] as String)))
        : const SqlValue.absent(),
    accountId: (json['accountId'] as String),
    providerId: (json['providerId'] as String),
    userId: AuthUserId((json['userId'] as String)),
    accessToken: json['accessToken'] == null ? null : (json['accessToken'] as String),
    refreshToken: json['refreshToken'] == null ? null : (json['refreshToken'] as String),
    idToken: json['idToken'] == null ? null : (json['idToken'] as String),
    accessTokenExpiresAt: json['accessTokenExpiresAt'] == null
        ? null
        : DateTime.parse((json['accessTokenExpiresAt'] as String)),
    refreshTokenExpiresAt: json['refreshTokenExpiresAt'] == null
        ? null
        : DateTime.parse((json['refreshTokenExpiresAt'] as String)),
    scope: json['scope'] == null ? null : (json['scope'] as String),
    password: json['password'] == null ? null : (json['password'] as String),
    createdAt: DateTime.parse((json['createdAt'] as String)),
    updatedAt: DateTime.parse((json['updatedAt'] as String)),
  );

  static const schemaId = 'AuthAccountInsert';

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const jsonSchema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'id': AuthAccountId.schema,
      'accountId': JsonSchema.string(),
      'providerId': JsonSchema.string(),
      'userId': AuthUserId.schema,
      'accessToken': JsonSchema.string(nullable: true),
      'refreshToken': JsonSchema.string(nullable: true),
      'idToken': JsonSchema.string(nullable: true),
      'accessTokenExpiresAt': JsonSchema.string(nullable: true, format: 'date-time'),
      'refreshTokenExpiresAt': JsonSchema.string(nullable: true, format: 'date-time'),
      'scope': JsonSchema.string(nullable: true),
      'password': JsonSchema.string(nullable: true),
      'createdAt': JsonSchema.string(format: 'date-time'),
      'updatedAt': JsonSchema.string(format: 'date-time'),
    },
    required: <String>[
      'accountId',
      'providerId',
      'userId',
      'accessToken',
      'refreshToken',
      'idToken',
      'accessTokenExpiresAt',
      'refreshTokenExpiresAt',
      'scope',
      'password',
      'createdAt',
      'updatedAt',
    ],
    additionalProperties: false,
  );

  final SqlValue<AuthAccountId> id;

  final String accountId;

  final String providerId;

  final AuthUserId userId;

  final String? accessToken;

  final String? refreshToken;

  final String? idToken;

  final DateTime? accessTokenExpiresAt;

  final DateTime? refreshTokenExpiresAt;

  final String? scope;

  final String? password;

  final DateTime createdAt;

  final DateTime updatedAt;

  AuthAccountInsert copyWith({
    SqlValue<AuthAccountId>? id,
    String? accountId,
    String? providerId,
    AuthUserId? userId,
    SqlValue<String?>? accessToken,
    SqlValue<String?>? refreshToken,
    SqlValue<String?>? idToken,
    SqlValue<DateTime?>? accessTokenExpiresAt,
    SqlValue<DateTime?>? refreshTokenExpiresAt,
    SqlValue<String?>? scope,
    SqlValue<String?>? password,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthAccountInsert(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      providerId: providerId ?? this.providerId,
      userId: userId ?? this.userId,
      accessToken: accessToken == null || !accessToken.isPresent
          ? this.accessToken
          : accessToken.value,
      refreshToken: refreshToken == null || !refreshToken.isPresent
          ? this.refreshToken
          : refreshToken.value,
      idToken: idToken == null || !idToken.isPresent ? this.idToken : idToken.value,
      accessTokenExpiresAt: accessTokenExpiresAt == null || !accessTokenExpiresAt.isPresent
          ? this.accessTokenExpiresAt
          : accessTokenExpiresAt.value,
      refreshTokenExpiresAt: refreshTokenExpiresAt == null || !refreshTokenExpiresAt.isPresent
          ? this.refreshTokenExpiresAt
          : refreshTokenExpiresAt.value,
      scope: scope == null || !scope.isPresent ? this.scope : scope.value,
      password: password == null || !password.isPresent ? this.password : password.value,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toColumns() => <String, Object?>{
    if (id.isPresent) 'id': id.value?.value,
    'accountId': accountId,
    'providerId': providerId,
    'userId': userId.value,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'idToken': idToken,
    'accessTokenExpiresAt': accessTokenExpiresAt,
    'refreshTokenExpiresAt': refreshTokenExpiresAt,
    'scope': scope,
    'password': password,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    if (id.isPresent) 'id': id.value?.value,
    'accountId': accountId,
    'providerId': providerId,
    'userId': userId.value,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'idToken': idToken,
    'accessTokenExpiresAt': accessTokenExpiresAt?.toIso8601String(),
    'refreshTokenExpiresAt': refreshTokenExpiresAt?.toIso8601String(),
    'scope': scope,
    'password': password,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  String toString() =>
      'AuthAccountInsert(id: $id, accountId: $accountId, providerId: $providerId, userId: $userId, accessToken: $accessToken, refreshToken: $refreshToken, idToken: $idToken, accessTokenExpiresAt: $accessTokenExpiresAt, refreshTokenExpiresAt: $refreshTokenExpiresAt, scope: $scope, password: $password, createdAt: $createdAt, updatedAt: $updatedAt)';
}

final class AuthAccountUpdate implements JsonEncodable {
  const AuthAccountUpdate({
    this.id = const SqlValue.absent(),
    this.accountId = const SqlValue.absent(),
    this.providerId = const SqlValue.absent(),
    this.userId = const SqlValue.absent(),
    this.accessToken = const SqlValue.absent(),
    this.refreshToken = const SqlValue.absent(),
    this.idToken = const SqlValue.absent(),
    this.accessTokenExpiresAt = const SqlValue.absent(),
    this.refreshTokenExpiresAt = const SqlValue.absent(),
    this.scope = const SqlValue.absent(),
    this.password = const SqlValue.absent(),
    this.createdAt = const SqlValue.absent(),
    this.updatedAt = const SqlValue.absent(),
  });

  factory AuthAccountUpdate.decode(Object? value) =>
      AuthAccountUpdate.fromJson(readJsonObject(value));

  factory AuthAccountUpdate.fromJson(Map<String, Object?> json) => AuthAccountUpdate(
    id: json.containsKey('id')
        ? SqlValue<AuthAccountId>(AuthAccountId((json['id'] as String)))
        : const SqlValue.absent(),
    accountId: json.containsKey('accountId')
        ? SqlValue<String>((json['accountId'] as String))
        : const SqlValue.absent(),
    providerId: json.containsKey('providerId')
        ? SqlValue<String>((json['providerId'] as String))
        : const SqlValue.absent(),
    userId: json.containsKey('userId')
        ? SqlValue<AuthUserId>(AuthUserId((json['userId'] as String)))
        : const SqlValue.absent(),
    accessToken: json.containsKey('accessToken')
        ? SqlValue<String?>(json['accessToken'] == null ? null : (json['accessToken'] as String))
        : const SqlValue.absent(),
    refreshToken: json.containsKey('refreshToken')
        ? SqlValue<String?>(json['refreshToken'] == null ? null : (json['refreshToken'] as String))
        : const SqlValue.absent(),
    idToken: json.containsKey('idToken')
        ? SqlValue<String?>(json['idToken'] == null ? null : (json['idToken'] as String))
        : const SqlValue.absent(),
    accessTokenExpiresAt: json.containsKey('accessTokenExpiresAt')
        ? SqlValue<DateTime?>(
            json['accessTokenExpiresAt'] == null
                ? null
                : DateTime.parse((json['accessTokenExpiresAt'] as String)),
          )
        : const SqlValue.absent(),
    refreshTokenExpiresAt: json.containsKey('refreshTokenExpiresAt')
        ? SqlValue<DateTime?>(
            json['refreshTokenExpiresAt'] == null
                ? null
                : DateTime.parse((json['refreshTokenExpiresAt'] as String)),
          )
        : const SqlValue.absent(),
    scope: json.containsKey('scope')
        ? SqlValue<String?>(json['scope'] == null ? null : (json['scope'] as String))
        : const SqlValue.absent(),
    password: json.containsKey('password')
        ? SqlValue<String?>(json['password'] == null ? null : (json['password'] as String))
        : const SqlValue.absent(),
    createdAt: json.containsKey('createdAt')
        ? SqlValue<DateTime>(DateTime.parse((json['createdAt'] as String)))
        : const SqlValue.absent(),
    updatedAt: json.containsKey('updatedAt')
        ? SqlValue<DateTime>(DateTime.parse((json['updatedAt'] as String)))
        : const SqlValue.absent(),
  );

  static const schemaId = 'AuthAccountUpdate';

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const jsonSchema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'id': AuthAccountId.schema,
      'accountId': JsonSchema.string(),
      'providerId': JsonSchema.string(),
      'userId': AuthUserId.schema,
      'accessToken': JsonSchema.string(nullable: true),
      'refreshToken': JsonSchema.string(nullable: true),
      'idToken': JsonSchema.string(nullable: true),
      'accessTokenExpiresAt': JsonSchema.string(nullable: true, format: 'date-time'),
      'refreshTokenExpiresAt': JsonSchema.string(nullable: true, format: 'date-time'),
      'scope': JsonSchema.string(nullable: true),
      'password': JsonSchema.string(nullable: true),
      'createdAt': JsonSchema.string(format: 'date-time'),
      'updatedAt': JsonSchema.string(format: 'date-time'),
    },
    required: <String>[],
    additionalProperties: false,
  );

  final SqlValue<AuthAccountId> id;

  final SqlValue<String> accountId;

  final SqlValue<String> providerId;

  final SqlValue<AuthUserId> userId;

  final SqlValue<String?> accessToken;

  final SqlValue<String?> refreshToken;

  final SqlValue<String?> idToken;

  final SqlValue<DateTime?> accessTokenExpiresAt;

  final SqlValue<DateTime?> refreshTokenExpiresAt;

  final SqlValue<String?> scope;

  final SqlValue<String?> password;

  final SqlValue<DateTime> createdAt;

  final SqlValue<DateTime> updatedAt;

  AuthAccountUpdate copyWith({
    SqlValue<AuthAccountId>? id,
    SqlValue<String>? accountId,
    SqlValue<String>? providerId,
    SqlValue<AuthUserId>? userId,
    SqlValue<String?>? accessToken,
    SqlValue<String?>? refreshToken,
    SqlValue<String?>? idToken,
    SqlValue<DateTime?>? accessTokenExpiresAt,
    SqlValue<DateTime?>? refreshTokenExpiresAt,
    SqlValue<String?>? scope,
    SqlValue<String?>? password,
    SqlValue<DateTime>? createdAt,
    SqlValue<DateTime>? updatedAt,
  }) {
    return AuthAccountUpdate(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      providerId: providerId ?? this.providerId,
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      idToken: idToken ?? this.idToken,
      accessTokenExpiresAt: accessTokenExpiresAt ?? this.accessTokenExpiresAt,
      refreshTokenExpiresAt: refreshTokenExpiresAt ?? this.refreshTokenExpiresAt,
      scope: scope ?? this.scope,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toColumns() => <String, Object?>{
    if (id.isPresent) 'id': id.value?.value,
    if (accountId.isPresent) 'accountId': accountId.value,
    if (providerId.isPresent) 'providerId': providerId.value,
    if (userId.isPresent) 'userId': userId.value?.value,
    if (accessToken.isPresent) 'accessToken': accessToken.value,
    if (refreshToken.isPresent) 'refreshToken': refreshToken.value,
    if (idToken.isPresent) 'idToken': idToken.value,
    if (accessTokenExpiresAt.isPresent) 'accessTokenExpiresAt': accessTokenExpiresAt.value,
    if (refreshTokenExpiresAt.isPresent) 'refreshTokenExpiresAt': refreshTokenExpiresAt.value,
    if (scope.isPresent) 'scope': scope.value,
    if (password.isPresent) 'password': password.value,
    if (createdAt.isPresent) 'createdAt': createdAt.value,
    if (updatedAt.isPresent) 'updatedAt': updatedAt.value,
  };

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    if (id.isPresent) 'id': id.value?.value,
    if (accountId.isPresent) 'accountId': accountId.value,
    if (providerId.isPresent) 'providerId': providerId.value,
    if (userId.isPresent) 'userId': userId.value?.value,
    if (accessToken.isPresent) 'accessToken': accessToken.value,
    if (refreshToken.isPresent) 'refreshToken': refreshToken.value,
    if (idToken.isPresent) 'idToken': idToken.value,
    if (accessTokenExpiresAt.isPresent)
      'accessTokenExpiresAt': accessTokenExpiresAt.value?.toIso8601String(),
    if (refreshTokenExpiresAt.isPresent)
      'refreshTokenExpiresAt': refreshTokenExpiresAt.value?.toIso8601String(),
    if (scope.isPresent) 'scope': scope.value,
    if (password.isPresent) 'password': password.value,
    if (createdAt.isPresent) 'createdAt': createdAt.value?.toIso8601String(),
    if (updatedAt.isPresent) 'updatedAt': updatedAt.value?.toIso8601String(),
  };

  @override
  String toString() =>
      'AuthAccountUpdate(id: $id, accountId: $accountId, providerId: $providerId, userId: $userId, accessToken: $accessToken, refreshToken: $refreshToken, idToken: $idToken, accessTokenExpiresAt: $accessTokenExpiresAt, refreshTokenExpiresAt: $refreshTokenExpiresAt, scope: $scope, password: $password, createdAt: $createdAt, updatedAt: $updatedAt)';
}

final class AuthAccountsTable
    extends SqlTable<AuthAccountRow, AuthAccountInsert, AuthAccountUpdate> {
  const AuthAccountsTable._() : schema = 'auth';

  const AuthAccountsTable.withSchema(this.schema);

  @override
  final String? schema;

  @override
  String get selectionPrefix => '${name}__';

  static const table = AuthAccountsTable._();

  static const id = SqlColumn<AuthAccountId>(
    table: AuthAccountsTable.withSchema(null),
    name: 'id',
    nullable: false,
    databaseType: 'text',
  );

  static const accountId = SqlColumn<String>(
    table: AuthAccountsTable.withSchema(null),
    name: 'accountId',
    nullable: false,
    databaseType: 'text',
  );

  static const providerId = SqlColumn<String>(
    table: AuthAccountsTable.withSchema(null),
    name: 'providerId',
    nullable: false,
    databaseType: 'text',
  );

  static const userId = SqlColumn<AuthUserId>(
    table: AuthAccountsTable.withSchema(null),
    name: 'userId',
    nullable: false,
    databaseType: 'text',
  );

  static const accessToken = SqlColumn<String>(
    table: AuthAccountsTable.withSchema(null),
    name: 'accessToken',
    nullable: true,
    databaseType: 'text',
  );

  static const refreshToken = SqlColumn<String>(
    table: AuthAccountsTable.withSchema(null),
    name: 'refreshToken',
    nullable: true,
    databaseType: 'text',
  );

  static const idToken = SqlColumn<String>(
    table: AuthAccountsTable.withSchema(null),
    name: 'idToken',
    nullable: true,
    databaseType: 'text',
  );

  static const accessTokenExpiresAt = SqlColumn<DateTime>(
    table: AuthAccountsTable.withSchema(null),
    name: 'accessTokenExpiresAt',
    nullable: true,
    databaseType: 'timestamptz',
  );

  static const refreshTokenExpiresAt = SqlColumn<DateTime>(
    table: AuthAccountsTable.withSchema(null),
    name: 'refreshTokenExpiresAt',
    nullable: true,
    databaseType: 'timestamptz',
  );

  static const scope = SqlColumn<String>(
    table: AuthAccountsTable.withSchema(null),
    name: 'scope',
    nullable: true,
    databaseType: 'text',
  );

  static const password = SqlColumn<String>(
    table: AuthAccountsTable.withSchema(null),
    name: 'password',
    nullable: true,
    databaseType: 'text',
  );

  static const createdAt = SqlColumn<DateTime>(
    table: AuthAccountsTable.withSchema(null),
    name: 'createdAt',
    nullable: false,
    databaseType: 'timestamptz',
  );

  static const updatedAt = SqlColumn<DateTime>(
    table: AuthAccountsTable.withSchema(null),
    name: 'updatedAt',
    nullable: false,
    databaseType: 'timestamptz',
  );

  @override
  String get name => 'account';

  @override
  List<SqlColumnBase> get columns => <SqlColumnBase>[
    id,
    accountId,
    providerId,
    userId,
    accessToken,
    refreshToken,
    idToken,
    accessTokenExpiresAt,
    refreshTokenExpiresAt,
    scope,
    password,
    createdAt,
    updatedAt,
  ];

  @override
  AuthAccountRow mapRow(SqlRow row, {String prefix = ''}) =>
      AuthAccountRow.fromSqlRow(row, prefix: prefix);

  @override
  Map<String, Object?> encodeInsert(AuthAccountInsert value) => value.toColumns();

  @override
  Map<String, Object?> encodeUpdate(AuthAccountUpdate value) => value.toColumns();
}
