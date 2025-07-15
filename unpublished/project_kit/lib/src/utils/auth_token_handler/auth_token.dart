import 'package:fresh_dio/fresh_dio.dart';

/// Обертка над OAuth2Token, чтобы напрямую не зависить от Fresh
/// и поддержать новые поля

class AuthToken extends OAuth2Token {
  final String? userId;

  const AuthToken({
    required super.accessToken,
    super.tokenType = 'bearer',
    super.expiresIn,
    super.refreshToken,
    super.scope,
    this.userId,
  });

  @override
  String toString() {
    return 'AuthToken(accessToken: $accessToken, tokenType: $tokenType, expiresIn: $expiresIn, refreshToken: $refreshToken, scope: $scope, userId: $userId)';
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'tokenType': tokenType,
      'expiresIn': expiresIn,
      'refreshToken': refreshToken,
      'scope': scope,
      'userId': userId,
    };
  }

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['accessToken'],
      tokenType: json['tokenType'],
      expiresIn: json['expiresIn'],
      refreshToken: json['refreshToken'],
      scope: json['scope'],
      userId: json['userId'],
    );
  }

  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    String? userId,
    String? tokenType,
    int? expiresIn,
    String? scope,
  }) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userId: userId ?? this.userId,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      scope: scope ?? this.scope,
    );
  }
}
