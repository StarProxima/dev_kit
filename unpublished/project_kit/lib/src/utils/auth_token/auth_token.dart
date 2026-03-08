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
      issuedAt:
          json['issuedAt'] == null ? null : DateTime.parse(json['issuedAt']),
      expiresAt:
          json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt']),
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
      tokenType: tokenType ?? this.tokenType,
      refreshToken: refreshToken ?? this.refreshToken,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    // ignore: avoid-adjacent-strings
    return 'AuthToken('
        'accessToken: $accessToken, '
        'tokenType: ${tokenType ?? 'null'}, '
        'refreshToken: ${refreshToken ?? 'null'}, '
        'expiresAt: ${expiresAt?.toIso8601String() ?? 'null'}, '
        'issuedAt: ${issuedAt?.toIso8601String() ?? 'null'}, '
        'userId: ${userId ?? 'null'})';
  }
}
