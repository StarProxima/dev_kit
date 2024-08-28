// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_token_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userAuthorizedHash() => r'e10e8b6cd23db18ae0cee057f90e0e883c58a368';

/// See also [userAuthorized].
@ProviderFor(userAuthorized)
final userAuthorizedProvider = Provider<bool>.internal(
  userAuthorized,
  name: r'userAuthorizedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userAuthorizedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UserAuthorizedRef = ProviderRef<bool>;
String _$userChangedHash() => r'8c2adffc3908d1693b8dc7df03d539305769a014';

/// See also [UserChanged].
@ProviderFor(UserChanged)
final userChangedProvider = NotifierProvider<UserChanged, void>.internal(
  UserChanged.new,
  name: r'userChangedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userChangedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserChanged = Notifier<void>;
String _$securityTokenStorageHash() =>
    r'5657cd9a2f3f056ff8d14790dc3fce26e9235e75';

/// Отвечает за управление и хранение токенов авторизации пользователя
///
/// Copied from [SecurityTokenStorage].
@ProviderFor(SecurityTokenStorage)
final securityTokenStorageProvider =
    AsyncNotifierProvider<SecurityTokenStorage, OAuth2Token?>.internal(
  SecurityTokenStorage.new,
  name: r'securityTokenStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$securityTokenStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SecurityTokenStorage = AsyncNotifier<OAuth2Token?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
