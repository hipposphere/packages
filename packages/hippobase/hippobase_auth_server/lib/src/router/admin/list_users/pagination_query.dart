import 'package:hippobase_core_models/hippobase_core_models.dart';

PaginationConfig decodeHippobaseAuthAdminPaginationQuery(
  Map<String, String> values, {
  required int defaultLimit,
}) {
  return PaginationConfig(
    offset: _parseInteger(values, 'offset') ?? 0,
    limit: _parseInteger(values, 'limit') ?? defaultLimit,
  );
}

int? _parseInteger(Map<String, String> values, String key) {
  final value = values[key];
  if (value == null || value.isEmpty) return null;
  return int.tryParse(value) ?? -1;
}
