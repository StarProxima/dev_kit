// ignore_for_file: avoid_positional_boolean_parameters

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../interfaces.dart';
import '../notifier_async_utils/notifier_async_utils.dart';
import 'auth_token.dart';

part 'security_token_storage.g.dart';

class FailedReadFromStorageException implements Exception {
  final Object error;
  final StackTrace stacktrace;

  const FailedReadFromStorageException({
    required this.stacktrace,
    required this.error,
  });

  @override
  String toString() {
    return 'FailedReadFromStorageException(error: $error, stacktrace: $stacktrace)';
  }
}

@Riverpod(keepAlive: true)
class UserChanged extends _$UserChanged {
  @override
  void build({String? id}) {
    ref.listen(
      securityTokenStorageProvider(id: id),
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
bool userAuthorized(Ref ref, {String? id}) {
  final token = ref.watch(securityTokenStorageProvider(id: id));

  return token.valueOrNull != null;
}

/// Отвечает за управление и хранение токенов авторизации пользователя.
@Riverpod(keepAlive: true)
class SecurityTokenStorage extends _$SecurityTokenStorage implements IRef, TokenStorage<AuthToken> {
  static const _encryptedStorageV1 = FlutterSecureStorage(
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
    ),
  );

  static const _refreshKeyV1 = 'refreshToken';
  static const _accessKeyV1 = 'accessToken';
  static const _userIdV1 = 'userId';

  String get _authTokenKeyV2 => '${id}_auth_token';

  @override
  Future<AuthToken?> build({String? id}) async {
    try {
      final token = await read();
      return token;
    } catch (e, s) {
      // ignore: unawaited_futures
      Future.error(e, s);
      return null;
    }
  }

  @override
  Future<void> delete() async {
    await _encryptedStorageV1.delete(key: _refreshKeyV1);
    await _encryptedStorageV1.delete(key: _accessKeyV1);
    await _encryptedStorageV1.delete(key: _userIdV1);

    await _encryptedStorageV2.delete(key: _authTokenKeyV2);

    setData(null);
  }

  @override
  Future<AuthToken?> read() async {
    try {
      final authTokenStr = await _encryptedStorageV2.read(key: _authTokenKeyV2);

      if (authTokenStr != null) {
        final authToken = AuthToken.fromJson(
          jsonDecode(authTokenStr),
        );

        return authToken;
      }

      try {
        final refreshToken = await _encryptedStorageV1.read(key: _refreshKeyV1);
        final accessToken = await _encryptedStorageV1.read(key: _accessKeyV1);
        final userId = await _encryptedStorageV1.read(key: _userIdV1);

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
        await _encryptedStorageV1.deleteAll();
        throw FailedReadFromStorageException(
          error: e,
          stacktrace: s,
        );
      }
    } catch (e, s) {
      await _encryptedStorageV2.deleteAll();
      await _encryptedStorageV1.deleteAll();
      throw FailedReadFromStorageException(
        error: e,
        stacktrace: s,
      );
    }
  }

  @override
  Future<void> write(AuthToken token) async {
    setData(token);

    final authTokenStr = jsonEncode(token.toJson());

    await _encryptedStorageV2.write(
      key: _authTokenKeyV2,
      value: authTokenStr,
    );

    await future;
  }
}
