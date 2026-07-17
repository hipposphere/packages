import 'package:dart_edge_sql/dart_edge_sql.dart';
import 'package:hippobase_core_models/hippobase_core_models.dart';
import 'package:hippobase_core_server/hippobase_core_server.dart';
import 'package:test/test.dart';

void main() {
  final executor = _FakeSqlExecutor();
  final users = _UsersTable();

  QuerySpec spec() {
    return QuerySpec(
      fields: <String, QueryField>{
        'email': QueryField.text(users.email),
        'created_at': QueryField.dateTime(users.createdAt),
        'age': QueryField.integer(users.age),
        'status': QueryField.text(users.status),
      },
      defaultSort: <SortTerm>[SortTerm(field: 'created_at', direction: SortDirection.desc)],
    );
  }

  test('applies pagination, sorting, and filters to selected queries', () {
    final query = ListQuery(
      pagination: paginationConfig(offset: 20, limit: 10),
      sort: <SortTerm>[SortTerm(field: 'email', direction: SortDirection.asc)],
      filter: andFilterGroup(<FieldFilter>[
        fieldFilter('status', FilterOperator.eq, 'active'),
        fieldFilter('age', FilterOperator.gte, 18),
        fieldFilter('email', FilterOperator.ilike, '%@hippolabs.org'),
      ]),
    );

    final statement = executor.typed
        .from(users)
        .select(<Object>[users.id, users.email])
        .applyListQuery(query, spec())
        .toStatement();

    expect(statement.sql, contains('WHERE'));
    expect(statement.sql, contains('ORDER BY'));
    expect(statement.sql, contains('LIMIT 10'));
    expect(statement.sql, contains('OFFSET 20'));
    expect(statement.sql, contains('"public"."users"."email" ASC'));
    expect(statement.sql, contains('"public"."users"."status" = @'));
    expect(statement.sql, contains('"public"."users"."age" >= @'));
    expect(statement.sql, contains('"public"."users"."email" ILIKE @'));
    expect(statement.namedParameters?.values, containsAll(<Object?>['active', 18]));
    expect(statement.namedParameters?.values, contains('%@hippolabs.org'));
  });

  test('uses default sort when query sort is empty', () {
    final query = ListQuery(pagination: paginationConfig(), sort: const <SortTerm>[]);

    final statement = executor.typed
        .from(users)
        .select(<Object>[users.id])
        .applyListQuery(query, spec())
        .toStatement();

    expect(statement.sql, contains('"public"."users"."createdAt" DESC'));
  });

  test('applies offset without a limit', () {
    final query = ListQuery(pagination: paginationConfig(offset: 20));

    final statement = executor.typed
        .from(users)
        .select(<Object>[users.id])
        .applyListQuery(query, spec())
        .toStatement();

    expect(statement.sql, contains('OFFSET 20'));
    expect(statement.sql, isNot(contains('LIMIT')));
  });

  test('rejects unknown query fields', () {
    final query = ListQuery(
      pagination: paginationConfig(),
      sort: <SortTerm>[SortTerm(field: 'not_allowed', direction: SortDirection.asc)],
    );

    expect(
      () => executor.typed.from(users).applyListQuery(query, spec()),
      throwsA(isA<QueryApplicationException>()),
    );
  });

  test('rejects pattern operators for non-pattern fields', () {
    final query = ListQuery(
      pagination: paginationConfig(),
      sort: const <SortTerm>[],
      filter: andFilterGroup(<FieldFilter>[fieldFilter('age', FilterOperator.contains, '2')]),
    );

    expect(
      () => executor.typed.from(users).applyListQuery(query, spec()),
      throwsA(isA<QueryApplicationException>()),
    );
  });

  test('applies not-in and between filters', () {
    final query = ListQuery(
      pagination: paginationConfig(),
      sort: const <SortTerm>[],
      filter: andFilterGroup(<FieldFilter>[
        fieldFilter('status', FilterOperator.notInList, <String>['archived', 'deleted']),
        fieldFilter('age', FilterOperator.between, <int>[18, 65]),
      ]),
    );

    final statement = executor.typed
        .from(users)
        .select(<Object>[users.id])
        .applyListQuery(query, spec())
        .toStatement();

    expect(statement.sql, contains('"public"."users"."status" NOT IN'));
    expect(statement.sql, contains('"public"."users"."age" BETWEEN @'));
    expect(
      statement.namedParameters?.values,
      containsAll(<Object?>['archived', 'deleted', 18, 65]),
    );
  });
}

final class _FakeSqlExecutor implements SqlExecutor {
  @override
  SqlDialect get dialect => SqlDialect.postgres;

  @override
  Future<SqlResult> execute(SqlStatement statement) async => SqlResult();
}

final class _UsersTable extends SqlTable<_UserRow, Map<String, Object?>, Map<String, Object?>> {
  @override
  String get name => 'users';

  @override
  String? get schema => 'public';

  @override
  List<SqlColumn<Object?>> get columns => <SqlColumn<Object?>>[
    id.asObjectColumn,
    email.asObjectColumn,
    status.asObjectColumn,
    age.asObjectColumn,
    createdAt.asObjectColumn,
  ];

  SqlColumn<int> get id => column<int>('id', nullable: false, databaseType: 'int4');

  SqlColumn<String> get email => column<String>('email', nullable: false, databaseType: 'text');

  SqlColumn<String> get status => column<String>('status', nullable: false, databaseType: 'text');

  SqlColumn<int> get age => column<int>('age', nullable: false, databaseType: 'int4');

  SqlColumn<DateTime> get createdAt =>
      column<DateTime>('createdAt', nullable: false, databaseType: 'timestamptz');

  @override
  Map<String, Object?> encodeInsert(Map<String, Object?> value) => value;

  @override
  Map<String, Object?> encodeUpdate(Map<String, Object?> value) => value;

  @override
  _UserRow mapRow(SqlRow row, {String prefix = ''}) => _UserRow();
}

final class _UserRow {}
