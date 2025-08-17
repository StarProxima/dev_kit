// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_token_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userAuthorizedHash() => r'6f0fe288f7edddab238230b2f9581d450b2723ce';

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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserAuthorizedRef = ProviderRef<bool>;
String _$secureTokenStorageIdHash() =>
    r'bedf0b60a7852edce618241ed1ddfc2c49748790';

/// Можно переопределить, чтобы использовать другой id для хранения токенов
/// Например, чтобы использовать разные стораджи для разных окружений
///
/// Copied from [secureTokenStorageId].
@ProviderFor(secureTokenStorageId)
final secureTokenStorageIdProvider = Provider<String?>.internal(
  secureTokenStorageId,
  name: r'secureTokenStorageIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$secureTokenStorageIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SecureTokenStorageIdRef = ProviderRef<String?>;
String _$userChangedHash() => r'b9ee8fe7f0bb096dc29e9e11229cac6d49e1b1c9';

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
String _$secureTokenStorageHash() =>
    r'f8e553ecee051ea0a8a58323a976a55324f7a32e';

/// Отвечает за управление и хранение токенов авторизации пользователя.
///
/// Copied from [SecureTokenStorage].
@ProviderFor(SecureTokenStorage)
final secureTokenStorageProvider =
    AsyncNotifierProvider<SecureTokenStorage, AuthToken?>.internal(
  SecureTokenStorage.new,
  name: r'secureTokenStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$secureTokenStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SecureTokenStorage = AsyncNotifier<AuthToken?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
