// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../interfaces.dart';
import '../notifier_async_utils/notifier_async_utils.dart';
import 'auth_token.dart';

part 'security_token_storage.g.dart';

class FailedReadFromStorageException implements Exception {
  final String message;
  final Object error;
  final StackTrace stacktrace;

  const FailedReadFromStorageException({
    required this.message,
    required this.stacktrace,
    required this.error,
  });
}

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
  static const _encryptedStorageV2 = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ));
  static const _refreshKey = 'refreshToken';
  static const _accessKey = 'accessToken';
  static const _userId = 'userId';
  static const _refreshKeyV2 = 'refreshTokenV2';
  static const _accessKeyV2 = 'accessTokenV2';
  static const _userIdV2 = 'userIdV2';

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
    await _encryptedStorageV2.delete(key: _refreshKeyV2);
    await _encryptedStorageV2.delete(key: _accessKeyV2);
    await _encryptedStorageV2.delete(key: _userIdV2);
    setData(null);
  }

  @override
  Future<AuthToken?> read() async {
    try {
      var refreshToken = await _encryptedStorageV2.read(key: _refreshKeyV2);
      var accessToken = await _encryptedStorageV2.read(key: _accessKeyV2);
      var userId = await _encryptedStorageV2.read(key: _userIdV2);

      if (accessToken != null && refreshToken != null) {
        return AuthToken(
          accessToken: accessToken,
          refreshToken: refreshToken,
          userId: userId,
        );
      }
      try {
        refreshToken = await _encryptedStorage.read(key: _refreshKey);
        accessToken = await _encryptedStorage.read(key: _accessKey);
        userId = await _encryptedStorage.read(key: _userId);

        if (accessToken == null || refreshToken == null) return null;

        final token = AuthToken(
          accessToken: accessToken,
          refreshToken: refreshToken,
          userId: userId,
        );
        // Сразу записываем старый токен в новый сторедж, так как он может быть еще валидным,
        // чтобы в следующий раз считать уже из нового стореджа
        await write(token);

        return token;
      } catch (e, s) {
        await _encryptedStorage.deleteAll();
        throw FailedReadFromStorageException(
          message: 'Failed read from encrypted storage!',
          error: e,
          stacktrace: s,
        );
      }
    } catch (e, s) {
      await _encryptedStorageV2.deleteAll();
      await _encryptedStorage.deleteAll();
      throw FailedReadFromStorageException(
        message: 'Failed read from encrypted storage!',
        error: e,
        stacktrace: s,
      );
    }
  }

  @override
  Future<void> write(AuthToken token) async {
    await _encryptedStorageV2.write(
      key: _refreshKeyV2,
      value: token.refreshToken,
    );
    await _encryptedStorageV2.write(
      key: _accessKeyV2,
      value: token.accessToken,
    );
    await _encryptedStorageV2.write(
      key: _userIdV2,
      value: token.userId?.toString(),
    );

    setData(
      AuthToken(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        userId: token.userId,
      ),
    );
    await future;
  }
}
