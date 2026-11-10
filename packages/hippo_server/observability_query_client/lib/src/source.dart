import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_http_core/dart_http_core.dart';
import 'package:observability_wire/observability_wire.dart';

/// One observability backend: its base URL, credentials and the transport that
/// reaches it. The source is read-only and safe to share.
///
/// Every call refuses redirects, so credentials never reach another host,
/// stops reading a response past [maxResponseBytes], gives up after [timeout],
/// and reports failures without the URL or credentials.
final class ObservabilitySource {
  ObservabilitySource({
    required this.baseUri,
    required this.transport,
    this.bearerToken,
    this.username,
    this.password,
    this.tenantId,
    this.headers = const {},
    this.timeout = const Duration(seconds: 15),
    this.maxResponseBytes = 16 * 1024 * 1024,
  });

  /// The backend's base URL; a reverse-proxy path prefix is kept.
  final Uri baseUri;
  final HttpClientTransport transport;
  final String? bearerToken;
  final String? username;
  final String? password;

  /// Sent as `X-Scope-OrgID`, for multi-tenant Loki and Tempo.
  final String? tenantId;

  /// Extra request headers.
  final Map<String, String> headers;
  final Duration timeout;
  final int maxResponseBytes;

  /// Text that must never appear in an error message.
  List<String> get secrets => [
    baseUri.toString(),
    baseUri.toString().replaceFirst(RegExp(r'/$'), ''),
    if (baseUri.host.isNotEmpty) baseUri.host,
    if (baseUri.hasAuthority) baseUri.authority,
    ?bearerToken,
    ?password,
    ?username,
    ?tenantId,
  ];

  Map<String, String> get _requestHeaders => {
    ...headers,
    'accept': 'application/json',
    if (bearerToken != null)
      'authorization': 'Bearer $bearerToken'
    else if (username != null)
      'authorization': 'Basic ${base64Encode(utf8.encode('$username:${password ?? ''}'))}',
    'X-Scope-OrgID': ?tenantId,
  };

  /// Runs [request] and returns its decoded JSON.
  ///
  /// Throws [ObservabilityUpstreamException] for a non-2xx answer (with the
  /// backend's own error text), a refused redirect, an oversized response, a
  /// timeout or an unreachable backend.
  Future<Object?> getJson(WireRequest request) async {
    final abort = Completer<void>();
    final uri = request.resolve(baseUri);
    try {
      return await _fetch(uri, abort).timeout(timeout);
    } on ObservabilityUpstreamException {
      rethrow;
    } on TimeoutException {
      if (!abort.isCompleted) abort.complete();
      throw ObservabilityUpstreamException(
        'The source did not answer within ${timeout.inSeconds} s',
      );
    } on Object {
      // Socket and TLS errors name the host; report a generic failure.
      throw const ObservabilityUpstreamException('The source is unreachable');
    }
  }

  Future<Object?> _fetch(Uri uri, Completer<void> abort) async {
    final response = await transport.sendStream(
      DartHttpClientRequest(
        method: HttpMethod.get,
        uri: uri,
        headers: _requestHeaders,
        redirectPolicy: DartHttpClientRedirectPolicy.none,
        abortTrigger: abort.future,
        responseMode: DartHttpClientResponseMode.stream,
      ),
    );
    final status = response.status;
    if (status >= 300 && status < 400) {
      unawaited(response.bodyStream.drain<void>().catchError((_) {}));
      throw ObservabilityUpstreamException(
        'The source answered with a redirect (HTTP $status), which is refused',
        statusCode: status,
      );
    }
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in response.bodyStream) {
      if (bytes.length + chunk.length > maxResponseBytes) {
        if (!abort.isCompleted) abort.complete();
        throw ObservabilityUpstreamException(
          'The response exceeds the ${_size(maxResponseBytes)} limit; '
          'narrow the query or the time range',
        );
      }
      bytes.add(chunk);
    }
    return decodeUpstreamJson(
      statusCode: status,
      body: utf8.decode(bytes.takeBytes(), allowMalformed: true),
      contentType: response.contentType.split(';').first.trim(),
      secrets: secrets,
    );
  }
}

String _size(int bytes) => bytes >= 1024 * 1024
    ? '${(bytes / (1024 * 1024)).toStringAsFixed(bytes % (1024 * 1024) == 0 ? 0 : 1)} MiB'
    : '${(bytes / 1024).round()} KiB';
