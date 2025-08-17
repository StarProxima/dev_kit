import 'package:fresh_dio/fresh_dio.dart';

class AuthToken extends Token {
  final DateTime? issuedAt;

  @override
  final DateTime? expiresAt;
  final String? userId;

  const AuthToken({
    required super.accessToken,
    super.tokenType,
    super.refreshToken,
    this.issuedAt,
    this.expiresAt,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'tokenType': tokenType,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt?.toIso8601String(),
      'issuedAt': issuedAt?.toIso8601String(),
      'userId': userId,
    };
  }

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['accessToken'],
      tokenType: json['tokenType'],
      refreshToken: json['refreshToken'],
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      issuedAt: json['issuedAt'] != null ? DateTime.parse(json['issuedAt']) : null,
      userId: json['userId'],
    );
  }

  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    DateTime? issuedAt,
    DateTime? expiresAt,
    String? userId,
  }) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'AuthToken(accessToken: $accessToken, tokenType: $tokenType, refreshToken: $refreshToken, expiresAt: $expiresAt, issuedAt: $issuedAt, userId: $userId)';
  }
}
