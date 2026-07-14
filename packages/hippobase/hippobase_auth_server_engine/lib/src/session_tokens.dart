import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

String hippobaseAuthTokenDigest(String token) => sha256.convert(utf8.encode(token)).toString();

const betterAuthSessionCookieName = 'better-auth.session_token';
const legacyBetterAuthSessionCookieName = 'better-auth.session-token';

final class HippobaseAuthSessionTokenCodec {
  HippobaseAuthSessionTokenCodec({
    required this.secret,
    required this.baseUrl,
    required this.cookieName,
  });

  final String secret;
  final Uri baseUrl;
  final String cookieName;

  String sign(String token) {
    final digest = Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(token));
    return '$token.${base64.encode(digest.bytes)}';
  }

  String? verifySigned(String value) {
    final split = value.lastIndexOf('.');
    if (split < 1) return null;
    final token = value.substring(0, split);
    final signature = value.substring(split + 1);
    List<int> decoded;
    try {
      decoded = base64.decode(signature);
    } on FormatException {
      return null;
    }
    final expected = Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(token)).bytes;
    return _constantTimeEquals(decoded, expected) ? token : null;
  }

  HippobaseAuthResolvedToken? resolve(Map<String, String> requestHeaders) {
    final headers = <String, String>{
      for (final entry in requestHeaders.entries) entry.key.toLowerCase(): entry.value,
    };
    final authorization = headers['authorization'];
    if (authorization != null) {
      final parts = authorization.trim().split(RegExp(r'\s+'));
      if (parts.length == 2 && parts.first.toLowerCase() == 'bearer') {
        final value = _decode(parts.last);
        return HippobaseAuthResolvedToken(verifySigned(value) ?? value, fromCookie: false);
      }
    }
    final cookies = headers['cookie'];
    if (cookies == null) return null;
    for (final name in cookieAliases(cookieName)) {
      final value = _cookieValue(cookies, name);
      if (value != null) {
        final decoded = _decode(value);
        return HippobaseAuthResolvedToken(verifySigned(decoded) ?? decoded, fromCookie: true);
      }
    }
    return null;
  }

  String setCookie(String token, DateTime expiresAt) {
    final name = _secureCookieName(cookieName);
    final value = Uri.encodeComponent(sign(token));
    return '$name=$value; Path=/; Expires=${HttpDate.format(expiresAt.toUtc())}; HttpOnly; SameSite=Lax${baseUrl.scheme == 'https' ? '; Secure' : ''}';
  }

  String expiredCookie() {
    final name = _secureCookieName(cookieName);
    return '$name=; Path=/; Expires=Thu, 01 Jan 1970 00:00:00 GMT; Max-Age=0; HttpOnly; SameSite=Lax${baseUrl.scheme == 'https' ? '; Secure' : ''}';
  }

  String _secureCookieName(String name) {
    if (baseUrl.scheme != 'https' || name.startsWith('__Secure-') || name.startsWith('__Host-')) {
      return name;
    }
    if (name == betterAuthSessionCookieName) return '__Secure-$name';
    return name;
  }
}

final class HippobaseAuthResolvedToken {
  const HippobaseAuthResolvedToken(this.token, {required this.fromCookie});

  final String token;
  final bool fromCookie;
}

List<String> cookieAliases([String? primary]) {
  final result = <String>[];
  void add(String? value) {
    if (value != null && value.isNotEmpty && !result.contains(value)) result.add(value);
  }

  add(primary);
  for (final name in const <String>[
    betterAuthSessionCookieName,
    'better-auth-session_token',
    legacyBetterAuthSessionCookieName,
  ]) {
    add(name);
    add('__Secure-$name');
    add('__Host-$name');
  }
  return result;
}

String? _cookieValue(String header, String name) {
  for (final part in header.split(';')) {
    final split = part.indexOf('=');
    if (split < 0 || part.substring(0, split).trim() != name) continue;
    final value = part.substring(split + 1).trim();
    if (value.isNotEmpty) return value;
  }
  return null;
}

String _decode(String value) {
  try {
    return Uri.decodeComponent(value);
  } on FormatException {
    return value;
  }
}

bool _constantTimeEquals(List<int> left, List<int> right) {
  var difference = left.length ^ right.length;
  final length = left.length < right.length ? left.length : right.length;
  for (var index = 0; index < length; index++) {
    difference |= left[index] ^ right[index];
  }
  return difference == 0;
}
