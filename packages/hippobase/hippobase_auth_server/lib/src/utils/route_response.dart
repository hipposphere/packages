import 'dart:async';

import 'package:dart_edge_core/dart_edge_core.dart';

import '../error.dart';

Future<RawResponse> hippobaseAuthJsonResponse<TServices>(
  RequestContext<TServices> context,
  FutureOr<Object?> Function() callback, {
  required String code,
  required String message,
  int defaultStatus = 500,
}) async {
  try {
    final result = await Future<Object?>.sync(callback);
    if (result case final RawResponse response) {
      return RawResponse(
        status: response.status,
        contentType: response.contentType,
        body: response.body,
        headers: <HttpHeader>[...context.res.headers, ...response.headers],
        isEncodedBody: response.isEncodedBody,
      );
    }
    return RawResponse.json(status: 200, body: result, headers: context.res.headers);
  } catch (error) {
    return hippobaseAuthExceptionResponse(
      error,
      defaultStatus: defaultStatus,
      defaultCode: code,
      defaultMessage: message,
    );
  }
}
