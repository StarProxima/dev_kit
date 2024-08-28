// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars, prefer_expression_function_bodies, unused_import, require_trailing_commas, library_private_types_in_public_api

part of 'security_token_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userAuthorizedHash() => r'8be5a35cf08bec16caec026df7f15d4542a5bd2b';

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
String _$userChangedHash() => r'f63b8885c578eb539b41dcf8424eed2f53931006';

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
String _$tokenStorageHash() => r'e02e879dd840006d6c90339976b5adbd1cc00b78';

/// Отвечает за управление и хранение токенов авторизации пользователя
///
/// Copied from [SecurityTokenStorage].
@ProviderFor(SecurityTokenStorage)
final securityTokenStorageProvider =
    AsyncNotifierProvider<SecurityTokenStorage, OAuth2Token?>.internal(
  SecurityTokenStorage.new,
  name: r'securityTokenStorageProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tokenStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SecurityTokenStorage = AsyncNotifier<OAuth2Token?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
