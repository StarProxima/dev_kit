// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars, prefer_expression_function_bodies, unused_import, require_trailing_commas, library_private_types_in_public_api

part of 'token_storage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TokenStorageStateImpl _$$TokenStorageStateImplFromJson(
        Map<String, dynamic> json) =>
    _$TokenStorageStateImpl(
      refreshToken: json['refreshToken'] as String,
      accessToken: json['accessToken'] as String,
    );

Map<String, dynamic> _$$TokenStorageStateImplToJson(
        _$TokenStorageStateImpl instance) =>
    <String, dynamic>{
      'refreshToken': instance.refreshToken,
      'accessToken': instance.accessToken,
    };

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
/// Copied from [TokenStorage].
@ProviderFor(TokenStorage)
final tokenStorageProvider =
    AsyncNotifierProvider<TokenStorage, TokenStorageState?>.internal(
  TokenStorage.new,
  name: r'tokenStorageProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tokenStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TokenStorage = AsyncNotifier<TokenStorageState?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
