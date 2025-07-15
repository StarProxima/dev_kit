import 'package:fresh_dio/fresh_dio.dart';

/// Обертка над OAuth2Token, чтобы напрямую не зависить от Fresh
/// и поддержать новые поля

class AuthToken extends OAuth2Token {
  final String? userId;
  final DateTime? refreshDate;

  const AuthToken({
    required super.accessToken,
    super.tokenType = 'bearer',
    super.refreshToken,
    super.scope,
    this.userId,
    this.refreshDate,
  });

  @override
  String toString() {
    return 'AuthToken(accessToken: $accessToken, tokenType: $tokenType, refreshToken: $refreshToken, scope: $scope, userId: $userId, refreshDate: $refreshDate)';
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'tokenType': tokenType,
      'refreshToken': refreshToken,
      'scope': scope,
      'userId': userId,
      'refreshDate': refreshDate?.toIso8601String(),
    };
  }

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['accessToken'],
      tokenType: json['tokenType'],
      refreshToken: json['refreshToken'],
      scope: json['scope'],
      userId: json['userId'],
      refreshDate: json['refreshDate'] != null ? DateTime.parse(json['refreshDate']) : null,
    );
  }

  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    String? userId,
    String? tokenType,
    String? scope,
    DateTime? refreshDate,
  }) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userId: userId ?? this.userId,
      tokenType: tokenType ?? this.tokenType,
      refreshDate: refreshDate ?? this.refreshDate,
      scope: scope ?? this.scope,
    );
  }
}
