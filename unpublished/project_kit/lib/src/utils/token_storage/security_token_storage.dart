// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../project_kit.dart';
import '../../internal/logger/dev_kit_logger.dart';
import '../notifier_async_utils/notifier_async_utils.dart';

part 'security_token_storage.g.dart';

@Riverpod(keepAlive: true)
class UserChanged extends _$UserChanged {
  @override
  void build() {
    ref.listen(securityTokenStorageProvider, (_, token) {
      if (token.requireValue != null) ref.invalidateSelf();
    });
  }

  @override
  bool updateShouldNotify(void previous, void next) => true;
}

@Riverpod(keepAlive: true)
bool userAuthorized(UserAuthorizedRef ref) {
  final token = ref.watch(securityTokenStorageProvider);
  return token.requireValue != null;
}

/// Отвечает за управление и хранение токенов авторизации пользователя
@Riverpod(keepAlive: true)
class SecurityTokenStorage extends _$SecurityTokenStorage
    implements IRef, TokenStorage<AuthToken> {
  static const _storage = FlutterSecureStorage();
  static const _refreshKey = 'refreshToken';
  static const _accessKey = 'accessToken';

  @override
  Future<AuthToken?> build() async {
    await read();
  }

  @override
  Future<void> delete() async {
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _accessKey);
    setData(null);
  }

  @override
  Future<AuthToken?> read() async {
    try {
      final refreshToken = await _storage.read(key: _refreshKey);
      final accessToken = await _storage.read(key: _accessKey);

      if (refreshToken == null || accessToken == null) return null;

      return AuthToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } catch (e, s) {
      logger.error(title: 'TokenStorage', error: e, stack: s);
      return null;
    }
  }

  @override
  Future<void> write(AuthToken token) async {
    await _storage.write(key: _refreshKey, value: token.refreshToken);
    await _storage.write(key: _accessKey, value: token.accessToken);

    setData(
      AuthToken(
        refreshToken: token.refreshToken,
        accessToken: token.accessToken,
      ),
    );
  }
}
