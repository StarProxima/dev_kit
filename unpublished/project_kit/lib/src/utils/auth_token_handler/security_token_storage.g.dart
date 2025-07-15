// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_token_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userAuthorizedHash() => r'8fe67d3a76f278b29b53c60de3595f0350a1f3ce';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [userAuthorized].
@ProviderFor(userAuthorized)
const userAuthorizedProvider = UserAuthorizedFamily();

/// See also [userAuthorized].
class UserAuthorizedFamily extends Family<bool> {
  /// See also [userAuthorized].
  const UserAuthorizedFamily();

  /// See also [userAuthorized].
  UserAuthorizedProvider call({
    String? id,
  }) {
    return UserAuthorizedProvider(
      id: id,
    );
  }

  @override
  UserAuthorizedProvider getProviderOverride(
    covariant UserAuthorizedProvider provider,
  ) {
    return call(
      id: provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userAuthorizedProvider';
}

/// See also [userAuthorized].
class UserAuthorizedProvider extends Provider<bool> {
  /// See also [userAuthorized].
  UserAuthorizedProvider({
    String? id,
  }) : this._internal(
          (ref) => userAuthorized(
            ref as UserAuthorizedRef,
            id: id,
          ),
          from: userAuthorizedProvider,
          name: r'userAuthorizedProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userAuthorizedHash,
          dependencies: UserAuthorizedFamily._dependencies,
          allTransitiveDependencies:
              UserAuthorizedFamily._allTransitiveDependencies,
          id: id,
        );

  UserAuthorizedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String? id;

  @override
  Override overrideWith(
    bool Function(UserAuthorizedRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserAuthorizedProvider._internal(
        (ref) => create(ref as UserAuthorizedRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  ProviderElement<bool> createElement() {
    return _UserAuthorizedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserAuthorizedProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserAuthorizedRef on ProviderRef<bool> {
  /// The parameter `id` of this provider.
  String? get id;
}

class _UserAuthorizedProviderElement extends ProviderElement<bool>
    with UserAuthorizedRef {
  _UserAuthorizedProviderElement(super.provider);

  @override
  String? get id => (origin as UserAuthorizedProvider).id;
}

String _$userChangedHash() => r'd0d3ba3fb9337c206119af2bb823c1075457884b';

abstract class _$UserChanged extends BuildlessNotifier<void> {
  late final String? id;

  void build({
    String? id,
  });
}

/// See also [UserChanged].
@ProviderFor(UserChanged)
const userChangedProvider = UserChangedFamily();

/// See also [UserChanged].
class UserChangedFamily extends Family<void> {
  /// See also [UserChanged].
  const UserChangedFamily();

  /// See also [UserChanged].
  UserChangedProvider call({
    String? id,
  }) {
    return UserChangedProvider(
      id: id,
    );
  }

  @override
  UserChangedProvider getProviderOverride(
    covariant UserChangedProvider provider,
  ) {
    return call(
      id: provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userChangedProvider';
}

/// See also [UserChanged].
class UserChangedProvider extends NotifierProviderImpl<UserChanged, void> {
  /// See also [UserChanged].
  UserChangedProvider({
    String? id,
  }) : this._internal(
          () => UserChanged()..id = id,
          from: userChangedProvider,
          name: r'userChangedProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userChangedHash,
          dependencies: UserChangedFamily._dependencies,
          allTransitiveDependencies:
              UserChangedFamily._allTransitiveDependencies,
          id: id,
        );

  UserChangedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String? id;

  @override
  void runNotifierBuild(
    covariant UserChanged notifier,
  ) {
    return notifier.build(
      id: id,
    );
  }

  @override
  Override overrideWith(UserChanged Function() create) {
    return ProviderOverride(
      origin: this,
      override: UserChangedProvider._internal(
        () => create()..id = id,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  NotifierProviderElement<UserChanged, void> createElement() {
    return _UserChangedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserChangedProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserChangedRef on NotifierProviderRef<void> {
  /// The parameter `id` of this provider.
  String? get id;
}

class _UserChangedProviderElement
    extends NotifierProviderElement<UserChanged, void> with UserChangedRef {
  _UserChangedProviderElement(super.provider);

  @override
  String? get id => (origin as UserChangedProvider).id;
}

String _$securityTokenStorageHash() =>
    r'45c8d0ab96b48422a8266ce33ab88e2dcfdd2507';

abstract class _$SecurityTokenStorage
    extends BuildlessAsyncNotifier<AuthToken?> {
  late final String? id;

  FutureOr<AuthToken?> build({
    String? id,
  });
}

/// Отвечает за управление и хранение токенов авторизации пользователя.
///
/// Copied from [SecurityTokenStorage].
@ProviderFor(SecurityTokenStorage)
const securityTokenStorageProvider = SecurityTokenStorageFamily();

/// Отвечает за управление и хранение токенов авторизации пользователя.
///
/// Copied from [SecurityTokenStorage].
class SecurityTokenStorageFamily extends Family<AsyncValue<AuthToken?>> {
  /// Отвечает за управление и хранение токенов авторизации пользователя.
  ///
  /// Copied from [SecurityTokenStorage].
  const SecurityTokenStorageFamily();

  /// Отвечает за управление и хранение токенов авторизации пользователя.
  ///
  /// Copied from [SecurityTokenStorage].
  SecurityTokenStorageProvider call({
    String? id,
  }) {
    return SecurityTokenStorageProvider(
      id: id,
    );
  }

  @override
  SecurityTokenStorageProvider getProviderOverride(
    covariant SecurityTokenStorageProvider provider,
  ) {
    return call(
      id: provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'securityTokenStorageProvider';
}

/// Отвечает за управление и хранение токенов авторизации пользователя.
///
/// Copied from [SecurityTokenStorage].
class SecurityTokenStorageProvider
    extends AsyncNotifierProviderImpl<SecurityTokenStorage, AuthToken?> {
  /// Отвечает за управление и хранение токенов авторизации пользователя.
  ///
  /// Copied from [SecurityTokenStorage].
  SecurityTokenStorageProvider({
    String? id,
  }) : this._internal(
          () => SecurityTokenStorage()..id = id,
          from: securityTokenStorageProvider,
          name: r'securityTokenStorageProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$securityTokenStorageHash,
          dependencies: SecurityTokenStorageFamily._dependencies,
          allTransitiveDependencies:
              SecurityTokenStorageFamily._allTransitiveDependencies,
          id: id,
        );

  SecurityTokenStorageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String? id;

  @override
  FutureOr<AuthToken?> runNotifierBuild(
    covariant SecurityTokenStorage notifier,
  ) {
    return notifier.build(
      id: id,
    );
  }

  @override
  Override overrideWith(SecurityTokenStorage Function() create) {
    return ProviderOverride(
      origin: this,
      override: SecurityTokenStorageProvider._internal(
        () => create()..id = id,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<SecurityTokenStorage, AuthToken?>
      createElement() {
    return _SecurityTokenStorageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SecurityTokenStorageProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SecurityTokenStorageRef on AsyncNotifierProviderRef<AuthToken?> {
  /// The parameter `id` of this provider.
  String? get id;
}

class _SecurityTokenStorageProviderElement
    extends AsyncNotifierProviderElement<SecurityTokenStorage, AuthToken?>
    with SecurityTokenStorageRef {
  _SecurityTokenStorageProviderElement(super.provider);

  @override
  String? get id => (origin as SecurityTokenStorageProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
