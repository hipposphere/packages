import 'package:hippobase_auth_client/hippobase_auth_client.dart';

sealed class HippobaseLoginError {
  const HippobaseLoginError();
}

final class HippobaseInvalidCredentials extends HippobaseLoginError {
  const HippobaseInvalidCredentials();
}

final class HippobaseEmptyCredentials extends HippobaseLoginError {
  const HippobaseEmptyCredentials();
}

final class HippobasePasswordTooShort extends HippobaseLoginError {
  const HippobasePasswordTooShort();
}

final class HippobaseUnknownLoginError extends HippobaseLoginError {
  const HippobaseUnknownLoginError(this.error);

  final Object error;
}

HippobaseLoginError hippobaseLoginError(Object error) {
  if (error case HippobaseAuthApiException(:final code)) {
    return switch (code) {
      'InvalidCredentials' ||
      'INVALID_EMAIL' ||
      'INVALID_EMAIL_OR_PASSWORD' => const HippobaseInvalidCredentials(),
      'PasswordTooShort' || 'PASSWORD_TOO_SHORT' => const HippobasePasswordTooShort(),
      _ => HippobaseUnknownLoginError(error),
    };
  }
  return HippobaseUnknownLoginError(error);
}

String hippobaseLoginErrorMessage(HippobaseLoginError error) {
  return switch (error) {
    HippobaseInvalidCredentials() => 'The email address or password is invalid.',
    HippobaseEmptyCredentials() => 'Email and password are required.',
    HippobasePasswordTooShort() => 'The password must contain at least 8 characters.',
    HippobaseUnknownLoginError(:final error) => 'Sign in failed: $error',
  };
}
