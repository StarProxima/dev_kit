import 'package:fresh_dio/fresh_dio.dart';

import '../model/auth_token.dart';

/// Обертка над Fresh, чтобы напрямую не зависить от него, а только от project_kit.
class AuthTokenHandler extends Fresh<AuthToken> {
  factory AuthTokenHandler({
    required TokenStorage<AuthToken> tokenStorage,
    Dio? httpClient,
    TokenHeaderBuilder<AuthToken>? tokenHeader,
    ShouldRefresh? shouldRefresh,
    required RefreshToken<AuthToken> refreshToken,
  }) {
    return AuthTokenHandler._(
      tokenHeader: tokenHeader ??
          (token) => {
                // ignore: avoid-nullable-interpolation
                'authorization': '${token.tokenType} ${token.accessToken}',
              },
      tokenStorage: tokenStorage,
      refreshToken: refreshToken,
      shouldRefresh: shouldRefresh,
      httpClient: httpClient,
    );
  }

  AuthTokenHandler._({
    required super.tokenHeader,
    required super.tokenStorage,
    required super.refreshToken,
    super.shouldRefresh,
    super.httpClient,
  });
}

class RevokeAuthTokenException implements RevokeTokenException {
  const RevokeAuthTokenException();
}
