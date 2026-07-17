import 'package:meta/meta.dart';
import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';

typedef _ErrorArgs = ({int hashcode, String? initialError});
typedef _ValidatorState = ({String? error, int validationCount});
typedef _ValidatorStoreState = Map<int, _ValidatorState>;

final _validatorStoreProvider =
    NotifierProvider<_ValidatorStore, _ValidatorStoreState>(
      _ValidatorStore.new,
      isAutoDispose: true,
    );

class _ValidatorStore extends Notifier<_ValidatorStoreState> {
  @override
  _ValidatorStoreState build() => {};

  _ValidatorState readState(int hashcode, {String? initialError}) {
    return state[hashcode] ?? (error: initialError, validationCount: 0);
  }

  void writeState(
    int hashcode,
    _ValidatorState next, {
    String? initialError,
  }) {
    final shouldRemove =
        next.validationCount == 0 && next.error == initialError;

    if (shouldRemove) {
      if (!state.containsKey(hashcode)) return;

      final newState = {...state}..remove(hashcode);
      state = newState;
      return;
    }

    state = {
      ...state,
      hashcode: next,
    };
  }

  void setError(
    int hashcode,
    String? error, {
    String? initialError,
  }) {
    final current = readState(hashcode, initialError: initialError);
    writeState(
      hashcode,
      (
        error: error,
        validationCount: current.validationCount,
      ),
      initialError: initialError,
    );
  }

  void incrementValidationCount(
    int hashcode, {
    String? initialError,
  }) {
    final current = readState(hashcode, initialError: initialError);
    writeState(
      hashcode,
      (
        error: current.error,
        validationCount: current.validationCount + 1,
      ),
      initialError: initialError,
    );
  }

  void decrementValidationCount(
    int hashcode, {
    String? initialError,
  }) {
    final current = readState(hashcode, initialError: initialError);
    writeState(
      hashcode,
      (
        error: current.error,
        validationCount: current.validationCount - 1,
      ),
      initialError: initialError,
    );
  }
}

final _errorProvider = Provider.family<String?, _ErrorArgs>(
  (ref, args) => ref.watch(
    _validatorStoreProvider.select(
      (state) => state[args.hashcode]?.error ?? args.initialError,
    ),
  ),
);

final _validationCountProvider = Provider.family<int, int>(
  (ref, hashcode) => ref.watch(
    _validatorStoreProvider.select(
      (state) => state[hashcode]?.validationCount ?? 0,
    ),
  ),
);

final _loadingProvider = Provider.family<bool, int>(
  (ref, hashcode) => ref.watch(_validationCountProvider(hashcode)) > 0,
);

@internal
class ValidatorRiverpodAdapter {
  ValidatorRiverpodAdapter(this._getRef);

  final Ref Function() _getRef;

  /// Ref берётся лениво на каждый вызов: Ref-объект провайдера умирает при
  /// каждой его пересборке, а notifier (и созданные им валидаторы) пересборку
  /// переживают. Захваченный в поле Ref после первой же пересборки бросал бы
  /// UnmountedRefException на каждую валидацию.
  Ref get ref => _getRef();

  ProviderBase<String?> createErrorProvider({
    required int hashcode,
    String? initialError,
  }) {
    return _errorProvider(
      (hashcode: hashcode, initialError: initialError),
    );
  }

  ProviderBase<bool> createLoadingProvider(int hashcode) {
    return _loadingProvider(hashcode);
  }

  ProviderBase<int> createValidationCountProvider(int hashcode) {
    return _validationCountProvider(hashcode);
  }

  T read<T>(ProviderListenable<T> provider) => ref.read(provider);

  bool exists(ProviderBase<Object?> provider) => ref.exists(provider);

  void setError(
    int hashcode,
    String? error, {
    String? initialError,
  }) {
    ref.read(_validatorStoreProvider.notifier).setError(
          hashcode,
          error,
          initialError: initialError,
        );
  }

  void incrementValidationCount(
    int hashcode, {
    String? initialError,
  }) {
    ref.read(_validatorStoreProvider.notifier).incrementValidationCount(
          hashcode,
          initialError: initialError,
        );
  }

  void decrementValidationCount(
    int hashcode, {
    String? initialError,
  }) {
    ref.read(_validatorStoreProvider.notifier).decrementValidationCount(
          hashcode,
          initialError: initialError,
        );
  }
}

mixin ValidatorRiverpodRef {
  Ref get ref;

  @protected
  ValidatorRiverpodAdapter get validatorRiverpod;
}
