import 'package:hippobase_auth_server_engine/hippobase_auth_server_engine.dart';
import 'package:test/test.dart';

void main() {
  final codec = HippobaseAuthSessionTokenCodec(
    secret: 'test-secret-key-that-is-at-least-32-characters-long',
    baseUrl: Uri.parse('https://auth.example.com'),
    cookieName: defaultHippobaseAuthSessionCookieName,
  );

  test('round-trips signed tokens in constant-time verified form', () {
    final signed = codec.sign('session_legacy');
    expect(codec.verifySigned(signed), 'session_legacy');
    expect(codec.verifySigned('${signed}x'), isNull);
  });

  test('resolves raw bearer tokens and Better Auth cookie aliases', () {
    final bearer = codec.resolve(const <String, String>{'authorization': 'Bearer session_bearer'});
    expect(bearer?.token, 'session_bearer');
    expect(bearer?.fromCookie, isFalse);

    final cookie = codec.resolve(<String, String>{
      'cookie': 'better-auth.session_token=${Uri.encodeComponent(codec.sign('session_cookie'))}',
    });
    expect(cookie?.token, 'session_cookie');
    expect(cookie?.fromCookie, isTrue);
  });
}
