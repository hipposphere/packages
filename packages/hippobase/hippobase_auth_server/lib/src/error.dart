import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_server_engine/hippobase_auth_server_engine.dart';

export 'package:hippobase_auth_server_engine/hippobase_auth_server_engine.dart'
    show HippobaseAuthException;

RawResponse hippobaseAuthErrorResponse(
  int status,
  String code,
  String message, {
  Map<String, Object?>? details,
}) {
  return RawResponse.json(
    status: status,
    body: <String, Object?>{
      'error': <String, Object?>{
        'code': code,
        'message': message,
        if (details != null && details.isNotEmpty) 'details': details,
      },
    },
  );
}

RawResponse hippobaseAuthExceptionResponse(
  Object error, {
  required int defaultStatus,
  required String defaultCode,
  required String defaultMessage,
}) {
  return switch (error) {
    HippobaseAuthException(:final status, :final code, :final message, :final details) =>
      hippobaseAuthErrorResponse(status, code, message, details: details),
    FormatException(:final message) => hippobaseAuthErrorResponse(400, 'InvalidRequest', message),
    _ => hippobaseAuthErrorResponse(defaultStatus, defaultCode, defaultMessage),
  };
}
