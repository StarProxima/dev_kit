import 'package:fresh_dio/fresh_dio.dart';

import '../model/auth_token.dart';

/// Обертка над Fresh, чтобы напрямую не зависить от него, а только от project_kit
class AuthTokenInterceptor extends Fresh<AuthToken> {
  AuthTokenInterceptor._({
    required super.tokenHeader,
    required super.tokenStorage,
    required super.refreshToken,
    super.shouldRefresh,
    super.httpClient,
  });

  factory AuthTokenInterceptor.build({
    required TokenStorage<AuthToken> tokenStorage,
    required RefreshToken<AuthToken> refreshToken,
    ShouldRefresh? shouldRefresh,
    Dio? httpClient,
    TokenHeaderBuilder<AuthToken>? tokenHeader,
  }) {
    return AuthTokenInterceptor._(
      tokenStorage: tokenStorage,
      refreshToken: refreshToken,
      shouldRefresh: shouldRefresh,
      httpClient: httpClient,
      tokenHeader: tokenHeader ??
          (token) {
            return {
              'authorization': '${token.tokenType} ${token.accessToken}',
            };
          },
    );
  }
}
