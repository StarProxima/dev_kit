// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../interfaces.dart';
import '../notifier_async_utils/notifier_async_utils.dart';
import 'auth_token.dart';

part 'security_token_storage.g.dart';

@Riverpod(keepAlive: true)
class UserChanged extends _$UserChanged {
  @override
  void build() {
    ref.listen(
      securityTokenStorageProvider,
      (asyncPrevToken, asyncCurrentToken) {
        if (asyncPrevToken == null) return;
        if (!asyncPrevToken.hasValue) return;
        final prevUserId = asyncPrevToken.requireValue?.userId;
        final currentUserId = asyncCurrentToken.requireValue?.userId;
        if (prevUserId != currentUserId) ref.invalidateSelf();
      },
    );
  }

  @override
  bool updateShouldNotify(void previous, void next) => true;
}

@Riverpod(keepAlive: true)
// ignore: prefer-boolean-prefixes
bool userAuthorized(UserAuthorizedRef ref) {
  try {
    final token = ref.watch(securityTokenStorageProvider);

    return token.requireValue != null;
  } catch (e) {
    return false;
  }
}

/// Отвечает за управление и хранение токенов авторизации пользователя.
@Riverpod(keepAlive: true)
class SecurityTokenStorage extends _$SecurityTokenStorage
    implements IRef, TokenStorage<AuthToken> {
  static const _encryptedStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  static const _refreshKey = 'refreshToken';
  static const _accessKey = 'accessToken';
  static const _userId = 'userId';

  @override
  Future<AuthToken?> build() async {
    try {
      final token = await read();
      return token;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete() async {
    await _encryptedStorage.delete(key: _refreshKey);
    await _encryptedStorage.delete(key: _accessKey);
    await _encryptedStorage.delete(key: _userId);
    setData(null);
  }

  @override
  Future<AuthToken?> read() async {
    final refreshToken = await _encryptedStorage.read(key: _refreshKey);
    final accessToken = await _encryptedStorage.read(key: _accessKey);
    final userId = await _encryptedStorage.read(key: _userId);

    if (accessToken == null || refreshToken == null) return null;

    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
    );
  }

  @override
  Future<void> write(AuthToken token) async {
    await _encryptedStorage.write(key: _refreshKey, value: token.refreshToken);
    await _encryptedStorage.write(key: _accessKey, value: token.accessToken);
    await _encryptedStorage.write(
      key: _userId,
      value: token.userId?.toString(),
    );

    setData(
      AuthToken(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        userId: token.userId,
      ),
    );
  }
}
