// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../dev_kit.dart';

part 'token_storage.freezed.dart';
part 'token_storage.g.dart';

@Riverpod(keepAlive: true)
class UserChanged extends _$UserChanged {
  @override
  void build() {
    ref.listen(tokenStorageProvider, (_, token) {
      if (token.requireValue != null) ref.invalidateSelf();
    });
  }

  @override
  bool updateShouldNotify(void previous, void next) => true;
}

@Riverpod(keepAlive: true)
bool userAuthorized(UserAuthorizedRef ref) {
  final token = ref.watch(tokenStorageProvider);
  return token.requireValue != null;
}

@freezed
class TokenStorageState with _$TokenStorageState {
  factory TokenStorageState({
    required String refreshToken,
    required String accessToken,
  }) = _TokenStorageState;

  factory TokenStorageState.fromJson(Map<String, dynamic> json) =>
      _$TokenStorageStateFromJson(json);
}

/// Отвечает за управление и хранение токенов авторизации пользователя
@Riverpod(keepAlive: true)
class TokenStorage extends _$TokenStorage implements IRef {
  static const _storage = FlutterSecureStorage();
  static const _refreshKey = 'refreshToken';
  static const _accessKey = 'accessToken';

  @override
  Future<TokenStorageState?> build() async {
    final (refreshToken, accessToken) = await (
      _storage.read(key: _refreshKey),
      _storage.read(key: _accessKey),
    ).wait;

    if (refreshToken == null || accessToken == null) return null;

    return TokenStorageState(
      refreshToken: refreshToken,
      accessToken: accessToken,
    );
  }

  void updateToken({
    required String refreshToken,
    required String accessToken,
  }) {
    _storage.write(key: _refreshKey, value: refreshToken);
    _storage.write(key: _accessKey, value: accessToken);

    setData(
      TokenStorageState(
        refreshToken: refreshToken,
        accessToken: accessToken,
      ),
    );
  }

  void clearToken() {
    _storage.delete(key: _refreshKey);
    _storage.delete(key: _accessKey);

    setData(null);
  }
}
