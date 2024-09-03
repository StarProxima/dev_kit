import 'package:fresh_dio/fresh_dio.dart';

/// Обертка над OAuth2Token, чтобы напрямую не зависить от Fresh.
class AuthToken extends OAuth2Token {
  final int? userId;

  const AuthToken({
    required super.accessToken,
    super.tokenType = 'bearer',
    super.expiresIn,
    super.refreshToken,
    super.scope,
    this.userId,
  });
}
