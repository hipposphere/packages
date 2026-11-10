import 'dart:convert';

/// A failed call to a source. [message] never contains the source's URL or
/// credentials: pass the secrets to [redactText] when building one.
final class ObservabilityUpstreamException implements Exception {
  const ObservabilityUpstreamException(this.message, {this.statusCode});

  final String message;

  /// The HTTP status, when the source answered.
  final int? statusCode;

  bool get notFound => statusCode == 404;

  /// The source rejected the request itself, such as a query syntax error.
  bool get rejected => statusCode != null && statusCode! >= 400 && statusCode! < 500;

  @override
  String toString() => message;
}

/// Removes [secrets] (URLs, hosts, tokens) and any other URL from [text], and
/// shortens it to 2000 characters. Secrets under three characters are kept:
/// they would redact ordinary words.
String redactText(String text, Iterable<String> secrets) {
  var result = text;
  final ordered = {
    for (final secret in secrets)
      if (secret.length >= 3) secret,
  }.toList()..sort((a, b) => b.length.compareTo(a.length));
  for (final secret in ordered) {
    result = result.replaceAll(secret, '[redacted]');
  }
  result = result.replaceAll(RegExp(r'https?://[^\s"]+'), '[redacted]').trim();
  return result.length > 2000 ? '${result.substring(0, 2000)}…' : result;
}

/// Decodes the JSON answer of a source.
///
/// A non-2xx answer, or a `{"status": "error"}` envelope, becomes an
/// [ObservabilityUpstreamException] carrying the source's own error text, which
/// is what someone fixing a query needs. Plain-text errors (Loki, Tempo) are
/// kept when short.
Object? decodeUpstreamJson({
  required int statusCode,
  required String body,
  String? contentType,
  Iterable<String> secrets = const [],
}) {
  Object? json;
  try {
    json = jsonDecode(body);
  } on FormatException {
    json = null;
  }
  if (statusCode >= 200 && statusCode < 300) {
    if (json == null) {
      throw const ObservabilityUpstreamException('The source returned invalid JSON');
    }
    if (json case {'status': 'error'}) {
      throw _errorFrom(json, statusCode, secrets);
    }
    return json;
  }
  if (json is Map) {
    throw _errorFrom(json, statusCode, secrets);
  }
  final text = body.trim();
  final plain =
      text.isNotEmpty &&
      text.length <= 4000 &&
      !text.startsWith('<') &&
      (contentType == null || contentType.startsWith('text/plain'));
  throw ObservabilityUpstreamException(
    plain ? redactText(text, secrets) : 'The source answered with HTTP $statusCode',
    statusCode: statusCode,
  );
}

ObservabilityUpstreamException _errorFrom(
  Map<Object?, Object?> json,
  int statusCode,
  Iterable<String> secrets,
) {
  final message = json['error'] ?? json['message'];
  return ObservabilityUpstreamException(
    message is String && message.trim().isNotEmpty
        ? redactText(message, secrets)
        : 'The source answered with HTTP $statusCode',
    statusCode: statusCode,
  );
}
