import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/api_exception.dart';

typedef HippobaseAuthTokenProvider = FutureOr<String?> Function();

final class HippobaseAuthHttpTransport {
  HippobaseAuthHttpTransport({
    required this.baseUrl,
    required this.tokenProvider,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client(),
       _ownsHttpClient = httpClient == null;

  final Uri baseUrl;
  final HippobaseAuthTokenProvider tokenProvider;
  final http.Client _http;
  final bool _ownsHttpClient;

  Future<Map<String, Object?>> request(
    String method,
    String path, {
    Map<String, Object?>? body,
    Map<String, String>? query,
    bool authenticated = false,
    String fallbackCode = 'AuthRequestFailed',
    String fallbackMessage = 'Authentication request failed.',
  }) async {
    final headers = <String, String>{'accept': 'application/json'};
    if (body != null) headers['content-type'] = 'application/json';
    if (authenticated) {
      final token = await Future<String?>.sync(tokenProvider);
      if (token != null) headers['authorization'] = 'Bearer $token';
    }

    final request = http.Request(method, uri(path, queryParameters: query))
      ..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);
    final response = await http.Response.fromStream(await _http.send(request));
    final decoded = response.body.isEmpty ? <String, Object?>{} : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _exception(
        response.statusCode,
        decoded,
        fallbackCode: fallbackCode,
        fallbackMessage: fallbackMessage,
      );
    }
    if (decoded is! Map) {
      throw const FormatException('Authentication response must be a JSON object.');
    }
    return Map<String, Object?>.from(decoded);
  }

  Uri uri(String path, {Map<String, String>? queryParameters}) {
    final base = baseUrl.toString().endsWith('/') ? baseUrl : Uri.parse('${baseUrl.toString()}/');
    return base.resolve(path).replace(queryParameters: queryParameters);
  }

  void close() {
    if (_ownsHttpClient) _http.close();
  }
}

HippobaseAuthApiException _exception(
  int status,
  Object? decoded, {
  required String fallbackCode,
  required String fallbackMessage,
}) {
  final envelope = decoded is Map ? Map<String, Object?>.from(decoded) : const <String, Object?>{};
  final rawError = envelope['error'];
  final error = rawError is Map ? Map<String, Object?>.from(rawError) : const <String, Object?>{};
  return HippobaseAuthApiException(
    status: status,
    code: error['code']?.toString() ?? fallbackCode,
    message: error['message']?.toString() ?? fallbackMessage,
    details: error['details'] is Map ? Map<String, Object?>.from(error['details']! as Map) : null,
  );
}
