// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../project_kit.dart';
import '../notifier_async_utils/notifier_async_utils.dart';

part 'security_token_storage.g.dart';

@Riverpod(keepAlive: true)
class UserChanged extends _$UserChanged {
  @override
  void build() {
    ref.listen(securityTokenStorageProvider,
        (asyncPrevToken, asyncCurrentToken) {
      if (asyncPrevToken == null) return;
      if (!asyncPrevToken.hasValue) return;
      final prevUserId = asyncPrevToken.requireValue?.userId;
      final currentUserId = asyncCurrentToken.requireValue?.userId;
      if (prevUserId != currentUserId) ref.invalidateSelf();
    });
  }

  @override
  bool updateShouldNotify(void previous, void next) => true;
}

@Riverpod(keepAlive: true)
bool userAuthorized(UserAuthorizedRef ref) {
  try {
    final token = ref.watch(securityTokenStorageProvider);
    return token.requireValue != null;
  } catch (e) {
    return false;
  }
}

/// Отвечает за управление и хранение токенов авторизации пользователя
@Riverpod(keepAlive: true)
class SecurityTokenStorage extends _$SecurityTokenStorage
    implements IRef, TokenStorage<AuthToken> {
  @Deprecated('Use _encryptedStorage instead')
  static const _storage = FlutterSecureStorage();
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
    final token = await read();
    return token;
  }

  @override
  Future<void> delete() async {
    await _encryptedStorage.delete(key: _refreshKey);
    await _encryptedStorage.delete(key: _accessKey);
    await _encryptedStorage.delete(key: _userId);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _userId);
    setData(null);
  }

  @override
  Future<AuthToken?> read() async {
    var refreshToken = await _encryptedStorage.read(key: _refreshKey);
    var accessToken = await _encryptedStorage.read(key: _accessKey);
    var userId = await _encryptedStorage.read(key: _userId);

    if (refreshToken == null || accessToken == null || userId == null) {
      refreshToken = await _storage.read(key: _refreshKey);
      accessToken = await _storage.read(key: _accessKey);
      userId = await _storage.read(key: _userId);
      if (refreshToken == null || accessToken == null || userId == null) {
        return null;
      }
      await _encryptedStorage.write(key: _refreshKey, value: refreshToken);
      await _encryptedStorage.write(key: _accessKey, value: accessToken);
      await _encryptedStorage.write(key: _userId, value: userId);
    }

    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: int.tryParse(userId),
    );
  }

  @override
  Future<void> write(AuthToken token) async {
    await _encryptedStorage.write(key: _refreshKey, value: token.refreshToken);
    await _encryptedStorage.write(key: _accessKey, value: token.accessToken);
    await _encryptedStorage.write(
        key: _userId, value: token.userId?.toString());

    setData(
      AuthToken(
        refreshToken: token.refreshToken,
        accessToken: token.accessToken,
        userId: token.userId,
      ),
    );
  }
}
