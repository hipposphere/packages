import 'package:dart_edge_core/dart_edge_core.dart';
import 'user.g.dart';

extension type const AuthPasskeyId(String value) {
  static const manifest = SqlKeyManifestEntry(
    dartType: 'AuthPasskeyId',
    baseDartType: 'String',
    schema: 'auth',
    table: 'passkey',
    column: 'id',
  );

  static const JsonSchema schema = .string(dartType: .value('AuthPasskeyId'));

  static const JsonSchema schemaNullable = .string(
    nullable: true,
    dartType: .value('AuthPasskeyId'),
  );
}

final class AuthPasskeyRow implements JsonEncodable {
  const AuthPasskeyRow({
    required this.id,
    required this.name,
    required this.publicKey,
    required this.userId,
    required this.credentialID,
    required this.counter,
    required this.deviceType,
    required this.backedUp,
    required this.transports,
    required this.createdAt,
    required this.aaguid,
  });

  factory AuthPasskeyRow.fromSqlRow(SqlRow row, {String prefix = ''}) =>
      AuthPasskeyRow(
        id: AuthPasskeyId(row.read<String>('${prefix}id')),
        name: row.readNullable<String>('${prefix}name'),
        publicKey: row.read<String>('${prefix}publicKey'),
        userId: AuthUserId(row.read<String>('${prefix}userId')),
        credentialID: row.read<String>('${prefix}credentialID'),
        counter: row.read<int>('${prefix}counter'),
        deviceType: row.read<String>('${prefix}deviceType'),
        backedUp: row.read<bool>('${prefix}backedUp'),
        transports: row.readNullable<String>('${prefix}transports'),
        createdAt: switch (row.readNullable<Object?>('${prefix}createdAt')) {
          null => null,
          final DateTime value => value,
          final String value => DateTime.parse(value),
          final value => value as DateTime,
        },
        aaguid: row.readNullable<String>('${prefix}aaguid'),
      );

  factory AuthPasskeyRow.fromColumns(
    Map<String, Object?> columns, {
    String prefix = '',
  }) => AuthPasskeyRow.fromSqlRow(SqlRow(columns), prefix: prefix);

  factory AuthPasskeyRow.decode(Object? value) =>
      AuthPasskeyRow.fromJson(readJsonObject(value));

  factory AuthPasskeyRow.fromJson(Map<String, Object?> json) => AuthPasskeyRow(
    id: AuthPasskeyId((json['id'] as String)),
    name: json['name'] == null ? null : (json['name'] as String),
    publicKey: (json['publicKey'] as String),
    userId: AuthUserId((json['userId'] as String)),
    credentialID: (json['credentialID'] as String),
    counter: (json['counter'] as num).toInt(),
    deviceType: (json['deviceType'] as String),
    backedUp: (json['backedUp'] as bool),
    transports: json['transports'] == null
        ? null
        : (json['transports'] as String),
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse((json['createdAt'] as String)),
    aaguid: json['aaguid'] == null ? null : (json['aaguid'] as String),
  );

  static const schemaId = 'AuthPasskeyRow';

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const jsonSchema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'id': AuthPasskeyId.schema,
      'name': JsonSchema.string(nullable: true),
      'publicKey': JsonSchema.string(),
      'userId': AuthUserId.schema,
      'credentialID': JsonSchema.string(),
      'counter': JsonSchema.integer(),
      'deviceType': JsonSchema.string(),
      'backedUp': JsonSchema.boolean(),
      'transports': JsonSchema.string(nullable: true),
      'createdAt': JsonSchema.string(nullable: true, format: 'date-time'),
      'aaguid': JsonSchema.string(nullable: true),
    },
    required: <String>[
      'id',
      'name',
      'publicKey',
      'userId',
      'credentialID',
      'counter',
      'deviceType',
      'backedUp',
      'transports',
      'createdAt',
      'aaguid',
    ],
    additionalProperties: false,
  );

  final AuthPasskeyId id;

  final String? name;

  final String publicKey;

  final AuthUserId userId;

  final String credentialID;

  final int counter;

  final String deviceType;

  final bool backedUp;

  final String? transports;

  final DateTime? createdAt;

  final String? aaguid;

  AuthPasskeyRow copyWith({
    AuthPasskeyId? id,
    SqlValue<String?>? name,
    String? publicKey,
    AuthUserId? userId,
    String? credentialID,
    int? counter,
    String? deviceType,
    bool? backedUp,
    SqlValue<String?>? transports,
    SqlValue<DateTime?>? createdAt,
    SqlValue<String?>? aaguid,
  }) {
    return AuthPasskeyRow(
      id: id ?? this.id,
      name: name == null || !name.isPresent ? this.name : name.value,
      publicKey: publicKey ?? this.publicKey,
      userId: userId ?? this.userId,
      credentialID: credentialID ?? this.credentialID,
      counter: counter ?? this.counter,
      deviceType: deviceType ?? this.deviceType,
      backedUp: backedUp ?? this.backedUp,
      transports: transports == null || !transports.isPresent
          ? this.transports
          : transports.value,
      createdAt: createdAt == null || !createdAt.isPresent
          ? this.createdAt
          : createdAt.value,
      aaguid: aaguid == null || !aaguid.isPresent ? this.aaguid : aaguid.value,
    );
  }

  Map<String, Object?> toColumns() => <String, Object?>{
    'id': id.value,
    'name': name,
    'publicKey': publicKey,
    'userId': userId.value,
    'credentialID': credentialID,
    'counter': counter,
    'deviceType': deviceType,
    'backedUp': backedUp,
    'transports': transports,
    'createdAt': createdAt,
    'aaguid': aaguid,
  };

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'id': id.value,
    'name': name,
    'publicKey': publicKey,
    'userId': userId.value,
    'credentialID': credentialID,
    'counter': counter,
    'deviceType': deviceType,
    'backedUp': backedUp,
    'transports': transports,
    'createdAt': createdAt?.toIso8601String(),
    'aaguid': aaguid,
  };

  @override
  String toString() =>
      'AuthPasskeyRow(id: $id, name: $name, publicKey: $publicKey, userId: $userId, credentialID: $credentialID, counter: $counter, deviceType: $deviceType, backedUp: $backedUp, transports: $transports, createdAt: $createdAt, aaguid: $aaguid)';
}

final class AuthPasskeyInsert implements JsonEncodable {
  const AuthPasskeyInsert({
    this.id = const SqlValue.absent(),
    required this.name,
    required this.publicKey,
    required this.userId,
    required this.credentialID,
    required this.counter,
    required this.deviceType,
    required this.backedUp,
    required this.transports,
    required this.createdAt,
    required this.aaguid,
  });

  factory AuthPasskeyInsert.decode(Object? value) =>
      AuthPasskeyInsert.fromJson(readJsonObject(value));

  factory AuthPasskeyInsert.fromJson(Map<String, Object?> json) =>
      AuthPasskeyInsert(
        id: json.containsKey('id')
            ? SqlValue<AuthPasskeyId>(AuthPasskeyId((json['id'] as String)))
            : const SqlValue.absent(),
        name: json['name'] == null ? null : (json['name'] as String),
        publicKey: (json['publicKey'] as String),
        userId: AuthUserId((json['userId'] as String)),
        credentialID: (json['credentialID'] as String),
        counter: (json['counter'] as num).toInt(),
        deviceType: (json['deviceType'] as String),
        backedUp: (json['backedUp'] as bool),
        transports: json['transports'] == null
            ? null
            : (json['transports'] as String),
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.parse((json['createdAt'] as String)),
        aaguid: json['aaguid'] == null ? null : (json['aaguid'] as String),
      );

  static const schemaId = 'AuthPasskeyInsert';

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const jsonSchema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'id': AuthPasskeyId.schema,
      'name': JsonSchema.string(nullable: true),
      'publicKey': JsonSchema.string(),
      'userId': AuthUserId.schema,
      'credentialID': JsonSchema.string(),
      'counter': JsonSchema.integer(),
      'deviceType': JsonSchema.string(),
      'backedUp': JsonSchema.boolean(),
      'transports': JsonSchema.string(nullable: true),
      'createdAt': JsonSchema.string(nullable: true, format: 'date-time'),
      'aaguid': JsonSchema.string(nullable: true),
    },
    required: <String>[
      'name',
      'publicKey',
      'userId',
      'credentialID',
      'counter',
      'deviceType',
      'backedUp',
      'transports',
      'createdAt',
      'aaguid',
    ],
    additionalProperties: false,
  );

  final SqlValue<AuthPasskeyId> id;

  final String? name;

  final String publicKey;

  final AuthUserId userId;

  final String credentialID;

  final int counter;

  final String deviceType;

  final bool backedUp;

  final String? transports;

  final DateTime? createdAt;

  final String? aaguid;

  AuthPasskeyInsert copyWith({
    SqlValue<AuthPasskeyId>? id,
    SqlValue<String?>? name,
    String? publicKey,
    AuthUserId? userId,
    String? credentialID,
    int? counter,
    String? deviceType,
    bool? backedUp,
    SqlValue<String?>? transports,
    SqlValue<DateTime?>? createdAt,
    SqlValue<String?>? aaguid,
  }) {
    return AuthPasskeyInsert(
      id: id ?? this.id,
      name: name == null || !name.isPresent ? this.name : name.value,
      publicKey: publicKey ?? this.publicKey,
      userId: userId ?? this.userId,
      credentialID: credentialID ?? this.credentialID,
      counter: counter ?? this.counter,
      deviceType: deviceType ?? this.deviceType,
      backedUp: backedUp ?? this.backedUp,
      transports: transports == null || !transports.isPresent
          ? this.transports
          : transports.value,
      createdAt: createdAt == null || !createdAt.isPresent
          ? this.createdAt
          : createdAt.value,
      aaguid: aaguid == null || !aaguid.isPresent ? this.aaguid : aaguid.value,
    );
  }

  Map<String, Object?> toColumns() => <String, Object?>{
    if (id.isPresent) 'id': id.value?.value,
    'name': name,
    'publicKey': publicKey,
    'userId': userId.value,
    'credentialID': credentialID,
    'counter': counter,
    'deviceType': deviceType,
    'backedUp': backedUp,
    'transports': transports,
    'createdAt': createdAt,
    'aaguid': aaguid,
  };

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    if (id.isPresent) 'id': id.value?.value,
    'name': name,
    'publicKey': publicKey,
    'userId': userId.value,
    'credentialID': credentialID,
    'counter': counter,
    'deviceType': deviceType,
    'backedUp': backedUp,
    'transports': transports,
    'createdAt': createdAt?.toIso8601String(),
    'aaguid': aaguid,
  };

  @override
  String toString() =>
      'AuthPasskeyInsert(id: $id, name: $name, publicKey: $publicKey, userId: $userId, credentialID: $credentialID, counter: $counter, deviceType: $deviceType, backedUp: $backedUp, transports: $transports, createdAt: $createdAt, aaguid: $aaguid)';
}

final class AuthPasskeyUpdate implements JsonEncodable {
  const AuthPasskeyUpdate({
    this.id = const SqlValue.absent(),
    this.name = const SqlValue.absent(),
    this.publicKey = const SqlValue.absent(),
    this.userId = const SqlValue.absent(),
    this.credentialID = const SqlValue.absent(),
    this.counter = const SqlValue.absent(),
    this.deviceType = const SqlValue.absent(),
    this.backedUp = const SqlValue.absent(),
    this.transports = const SqlValue.absent(),
    this.createdAt = const SqlValue.absent(),
    this.aaguid = const SqlValue.absent(),
  });

  factory AuthPasskeyUpdate.decode(Object? value) =>
      AuthPasskeyUpdate.fromJson(readJsonObject(value));

  factory AuthPasskeyUpdate.fromJson(Map<String, Object?> json) =>
      AuthPasskeyUpdate(
        id: json.containsKey('id')
            ? SqlValue<AuthPasskeyId>(AuthPasskeyId((json['id'] as String)))
            : const SqlValue.absent(),
        name: json.containsKey('name')
            ? SqlValue<String?>(
                json['name'] == null ? null : (json['name'] as String),
              )
            : const SqlValue.absent(),
        publicKey: json.containsKey('publicKey')
            ? SqlValue<String>((json['publicKey'] as String))
            : const SqlValue.absent(),
        userId: json.containsKey('userId')
            ? SqlValue<AuthUserId>(AuthUserId((json['userId'] as String)))
            : const SqlValue.absent(),
        credentialID: json.containsKey('credentialID')
            ? SqlValue<String>((json['credentialID'] as String))
            : const SqlValue.absent(),
        counter: json.containsKey('counter')
            ? SqlValue<int>((json['counter'] as num).toInt())
            : const SqlValue.absent(),
        deviceType: json.containsKey('deviceType')
            ? SqlValue<String>((json['deviceType'] as String))
            : const SqlValue.absent(),
        backedUp: json.containsKey('backedUp')
            ? SqlValue<bool>((json['backedUp'] as bool))
            : const SqlValue.absent(),
        transports: json.containsKey('transports')
            ? SqlValue<String?>(
                json['transports'] == null
                    ? null
                    : (json['transports'] as String),
              )
            : const SqlValue.absent(),
        createdAt: json.containsKey('createdAt')
            ? SqlValue<DateTime?>(
                json['createdAt'] == null
                    ? null
                    : DateTime.parse((json['createdAt'] as String)),
              )
            : const SqlValue.absent(),
        aaguid: json.containsKey('aaguid')
            ? SqlValue<String?>(
                json['aaguid'] == null ? null : (json['aaguid'] as String),
              )
            : const SqlValue.absent(),
      );

  static const schemaId = 'AuthPasskeyUpdate';

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const jsonSchema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'id': AuthPasskeyId.schema,
      'name': JsonSchema.string(nullable: true),
      'publicKey': JsonSchema.string(),
      'userId': AuthUserId.schema,
      'credentialID': JsonSchema.string(),
      'counter': JsonSchema.integer(),
      'deviceType': JsonSchema.string(),
      'backedUp': JsonSchema.boolean(),
      'transports': JsonSchema.string(nullable: true),
      'createdAt': JsonSchema.string(nullable: true, format: 'date-time'),
      'aaguid': JsonSchema.string(nullable: true),
    },
    required: <String>[],
    additionalProperties: false,
  );

  final SqlValue<AuthPasskeyId> id;

  final SqlValue<String?> name;

  final SqlValue<String> publicKey;

  final SqlValue<AuthUserId> userId;

  final SqlValue<String> credentialID;

  final SqlValue<int> counter;

  final SqlValue<String> deviceType;

  final SqlValue<bool> backedUp;

  final SqlValue<String?> transports;

  final SqlValue<DateTime?> createdAt;

  final SqlValue<String?> aaguid;

  AuthPasskeyUpdate copyWith({
    SqlValue<AuthPasskeyId>? id,
    SqlValue<String?>? name,
    SqlValue<String>? publicKey,
    SqlValue<AuthUserId>? userId,
    SqlValue<String>? credentialID,
    SqlValue<int>? counter,
    SqlValue<String>? deviceType,
    SqlValue<bool>? backedUp,
    SqlValue<String?>? transports,
    SqlValue<DateTime?>? createdAt,
    SqlValue<String?>? aaguid,
  }) {
    return AuthPasskeyUpdate(
      id: id ?? this.id,
      name: name ?? this.name,
      publicKey: publicKey ?? this.publicKey,
      userId: userId ?? this.userId,
      credentialID: credentialID ?? this.credentialID,
      counter: counter ?? this.counter,
      deviceType: deviceType ?? this.deviceType,
      backedUp: backedUp ?? this.backedUp,
      transports: transports ?? this.transports,
      createdAt: createdAt ?? this.createdAt,
      aaguid: aaguid ?? this.aaguid,
    );
  }

  Map<String, Object?> toColumns() => <String, Object?>{
    if (id.isPresent) 'id': id.value?.value,
    if (name.isPresent) 'name': name.value,
    if (publicKey.isPresent) 'publicKey': publicKey.value,
    if (userId.isPresent) 'userId': userId.value?.value,
    if (credentialID.isPresent) 'credentialID': credentialID.value,
    if (counter.isPresent) 'counter': counter.value,
    if (deviceType.isPresent) 'deviceType': deviceType.value,
    if (backedUp.isPresent) 'backedUp': backedUp.value,
    if (transports.isPresent) 'transports': transports.value,
    if (createdAt.isPresent) 'createdAt': createdAt.value,
    if (aaguid.isPresent) 'aaguid': aaguid.value,
  };

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    if (id.isPresent) 'id': id.value?.value,
    if (name.isPresent) 'name': name.value,
    if (publicKey.isPresent) 'publicKey': publicKey.value,
    if (userId.isPresent) 'userId': userId.value?.value,
    if (credentialID.isPresent) 'credentialID': credentialID.value,
    if (counter.isPresent) 'counter': counter.value,
    if (deviceType.isPresent) 'deviceType': deviceType.value,
    if (backedUp.isPresent) 'backedUp': backedUp.value,
    if (transports.isPresent) 'transports': transports.value,
    if (createdAt.isPresent) 'createdAt': createdAt.value?.toIso8601String(),
    if (aaguid.isPresent) 'aaguid': aaguid.value,
  };

  @override
  String toString() =>
      'AuthPasskeyUpdate(id: $id, name: $name, publicKey: $publicKey, userId: $userId, credentialID: $credentialID, counter: $counter, deviceType: $deviceType, backedUp: $backedUp, transports: $transports, createdAt: $createdAt, aaguid: $aaguid)';
}

final class AuthPasskeysTable
    extends SqlTable<AuthPasskeyRow, AuthPasskeyInsert, AuthPasskeyUpdate> {
  const AuthPasskeysTable._() : schema = 'auth';

  const AuthPasskeysTable.withSchema(this.schema);

  @override
  final String? schema;

  static const table = AuthPasskeysTable._();

  static const id = SqlColumn<AuthPasskeyId>(
    table: table,
    name: 'id',
    nullable: false,
    databaseType: 'text',
  );

  static const nameColumn = SqlColumn<String>(
    table: table,
    name: 'name',
    nullable: true,
    databaseType: 'text',
  );

  static const publicKey = SqlColumn<String>(
    table: table,
    name: 'publicKey',
    nullable: false,
    databaseType: 'text',
  );

  static const userId = SqlColumn<AuthUserId>(
    table: table,
    name: 'userId',
    nullable: false,
    databaseType: 'text',
  );

  static const credentialID = SqlColumn<String>(
    table: table,
    name: 'credentialID',
    nullable: false,
    databaseType: 'text',
  );

  static const counter = SqlColumn<int>(
    table: table,
    name: 'counter',
    nullable: false,
    databaseType: 'int4',
  );

  static const deviceType = SqlColumn<String>(
    table: table,
    name: 'deviceType',
    nullable: false,
    databaseType: 'text',
  );

  static const backedUp = SqlColumn<bool>(
    table: table,
    name: 'backedUp',
    nullable: false,
    databaseType: 'bool',
  );

  static const transports = SqlColumn<String>(
    table: table,
    name: 'transports',
    nullable: true,
    databaseType: 'text',
  );

  static const createdAt = SqlColumn<DateTime>(
    table: table,
    name: 'createdAt',
    nullable: true,
    databaseType: 'timestamptz',
  );

  static const aaguid = SqlColumn<String>(
    table: table,
    name: 'aaguid',
    nullable: true,
    databaseType: 'text',
  );

  @override
  String get name => 'passkey';

  @override
  List<SqlColumnBase> get columns => <SqlColumnBase>[
    id,
    nameColumn,
    publicKey,
    userId,
    credentialID,
    counter,
    deviceType,
    backedUp,
    transports,
    createdAt,
    aaguid,
  ];

  @override
  AuthPasskeyRow mapRow(SqlRow row, {String prefix = ''}) =>
      AuthPasskeyRow.fromSqlRow(row, prefix: prefix);

  @override
  Map<String, Object?> encodeInsert(AuthPasskeyInsert value) =>
      value.toColumns();

  @override
  Map<String, Object?> encodeUpdate(AuthPasskeyUpdate value) =>
      value.toColumns();
}
