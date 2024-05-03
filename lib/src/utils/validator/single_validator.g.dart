// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars, prefer_expression_function_bodies, unused_import, require_trailing_commas, library_private_types_in_public_api

part of 'single_validator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$loadingHash() => r'5f818f81d04be7dda7903caf45ad4b5d20a132b8';

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

/// See also [_loading].
@ProviderFor(_loading)
const _loadingProvider = _LoadingFamily();

/// See also [_loading].
class _LoadingFamily extends Family<bool> {
  /// See also [_loading].
  const _LoadingFamily();

  /// See also [_loading].
  _LoadingProvider call(
    int hashcode,
  ) {
    return _LoadingProvider(
      hashcode,
    );
  }

  @override
  _LoadingProvider getProviderOverride(
    covariant _LoadingProvider provider,
  ) {
    return call(
      provider.hashcode,
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
  String? get name => r'_loadingProvider';
}

/// See also [_loading].
class _LoadingProvider extends AutoDisposeProvider<bool> {
  /// See also [_loading].
  _LoadingProvider(
    int hashcode,
  ) : this._internal(
          (ref) => _loading(
            ref as _LoadingRef,
            hashcode,
          ),
          from: _loadingProvider,
          name: r'_loadingProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$loadingHash,
          dependencies: _LoadingFamily._dependencies,
          allTransitiveDependencies: _LoadingFamily._allTransitiveDependencies,
          hashcode: hashcode,
        );

  _LoadingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.hashcode,
  }) : super.internal();

  final int hashcode;

  @override
  Override overrideWith(
    bool Function(_LoadingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _LoadingProvider._internal(
        (ref) => create(ref as _LoadingRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        hashcode: hashcode,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _LoadingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _LoadingProvider && other.hashcode == hashcode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, hashcode.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin _LoadingRef on AutoDisposeProviderRef<bool> {
  /// The parameter `hashcode` of this provider.
  int get hashcode;
}

class _LoadingProviderElement extends AutoDisposeProviderElement<bool>
    with _LoadingRef {
  _LoadingProviderElement(super.provider);

  @override
  int get hashcode => (origin as _LoadingProvider).hashcode;
}

String _$errorHash() => r'1bbf57492cb8192e9ae8058c11e338d511e414ac';

abstract class _$Error extends BuildlessAutoDisposeNotifier<String?> {
  late final int hashcode;
  late final String? initialError;

  String? build(
    int hashcode,
    String? initialError,
  );
}

/// See also [_Error].
@ProviderFor(_Error)
const _errorProvider = _ErrorFamily();

/// See also [_Error].
class _ErrorFamily extends Family<String?> {
  /// See also [_Error].
  const _ErrorFamily();

  /// See also [_Error].
  _ErrorProvider call(
    int hashcode,
    String? initialError,
  ) {
    return _ErrorProvider(
      hashcode,
      initialError,
    );
  }

  @override
  _ErrorProvider getProviderOverride(
    covariant _ErrorProvider provider,
  ) {
    return call(
      provider.hashcode,
      provider.initialError,
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
  String? get name => r'_errorProvider';
}

/// See also [_Error].
class _ErrorProvider extends AutoDisposeNotifierProviderImpl<_Error, String?> {
  /// See also [_Error].
  _ErrorProvider(
    int hashcode,
    String? initialError,
  ) : this._internal(
          () => _Error()
            ..hashcode = hashcode
            ..initialError = initialError,
          from: _errorProvider,
          name: r'_errorProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$errorHash,
          dependencies: _ErrorFamily._dependencies,
          allTransitiveDependencies: _ErrorFamily._allTransitiveDependencies,
          hashcode: hashcode,
          initialError: initialError,
        );

  _ErrorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.hashcode,
    required this.initialError,
  }) : super.internal();

  final int hashcode;
  final String? initialError;

  @override
  String? runNotifierBuild(
    covariant _Error notifier,
  ) {
    return notifier.build(
      hashcode,
      initialError,
    );
  }

  @override
  Override overrideWith(_Error Function() create) {
    return ProviderOverride(
      origin: this,
      override: _ErrorProvider._internal(
        () => create()
          ..hashcode = hashcode
          ..initialError = initialError,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        hashcode: hashcode,
        initialError: initialError,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<_Error, String?> createElement() {
    return _ErrorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _ErrorProvider &&
        other.hashcode == hashcode &&
        other.initialError == initialError;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, hashcode.hashCode);
    hash = _SystemHash.combine(hash, initialError.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin _ErrorRef on AutoDisposeNotifierProviderRef<String?> {
  /// The parameter `hashcode` of this provider.
  int get hashcode;

  /// The parameter `initialError` of this provider.
  String? get initialError;
}

class _ErrorProviderElement
    extends AutoDisposeNotifierProviderElement<_Error, String?> with _ErrorRef {
  _ErrorProviderElement(super.provider);

  @override
  int get hashcode => (origin as _ErrorProvider).hashcode;
  @override
  String? get initialError => (origin as _ErrorProvider).initialError;
}

String _$validationCountHash() => r'fe7a61a380408c0fe7573bd590214f03ae266457';

abstract class _$ValidationCount extends BuildlessAutoDisposeNotifier<int> {
  late final int hashcode;

  int build(
    int hashcode,
  );
}

/// See also [_ValidationCount].
@ProviderFor(_ValidationCount)
const _validationCountProvider = _ValidationCountFamily();

/// See also [_ValidationCount].
class _ValidationCountFamily extends Family<int> {
  /// See also [_ValidationCount].
  const _ValidationCountFamily();

  /// See also [_ValidationCount].
  _ValidationCountProvider call(
    int hashcode,
  ) {
    return _ValidationCountProvider(
      hashcode,
    );
  }

  @override
  _ValidationCountProvider getProviderOverride(
    covariant _ValidationCountProvider provider,
  ) {
    return call(
      provider.hashcode,
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
  String? get name => r'_validationCountProvider';
}

/// See also [_ValidationCount].
class _ValidationCountProvider
    extends AutoDisposeNotifierProviderImpl<_ValidationCount, int> {
  /// See also [_ValidationCount].
  _ValidationCountProvider(
    int hashcode,
  ) : this._internal(
          () => _ValidationCount()..hashcode = hashcode,
          from: _validationCountProvider,
          name: r'_validationCountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$validationCountHash,
          dependencies: _ValidationCountFamily._dependencies,
          allTransitiveDependencies:
              _ValidationCountFamily._allTransitiveDependencies,
          hashcode: hashcode,
        );

  _ValidationCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.hashcode,
  }) : super.internal();

  final int hashcode;

  @override
  int runNotifierBuild(
    covariant _ValidationCount notifier,
  ) {
    return notifier.build(
      hashcode,
    );
  }

  @override
  Override overrideWith(_ValidationCount Function() create) {
    return ProviderOverride(
      origin: this,
      override: _ValidationCountProvider._internal(
        () => create()..hashcode = hashcode,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        hashcode: hashcode,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<_ValidationCount, int> createElement() {
    return _ValidationCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _ValidationCountProvider && other.hashcode == hashcode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, hashcode.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin _ValidationCountRef on AutoDisposeNotifierProviderRef<int> {
  /// The parameter `hashcode` of this provider.
  int get hashcode;
}

class _ValidationCountProviderElement
    extends AutoDisposeNotifierProviderElement<_ValidationCount, int>
    with _ValidationCountRef {
  _ValidationCountProviderElement(super.provider);

  @override
  int get hashcode => (origin as _ValidationCountProvider).hashcode;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
