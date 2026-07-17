import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_validator/riverpod_validator.dart';
import 'package:test/test.dart';

final _syncValidatorHostProvider =
    NotifierProvider<_SyncValidatorHost, void>(_SyncValidatorHost.new);

class _SyncValidatorHost extends Notifier<void> with ValidatorMixin {
  String value = '';
  String secondaryValue = '';

  late final requiredValidator = createValidator<String>(
    () => value,
    (state) => state.isEmpty ? 'Required' : null,
    label: 'value',
  );

  late final secondaryValidator = createValidator<String>(
    () => secondaryValue,
    (state) => state.length < 3 ? 'Too short' : null,
    label: 'secondary',
  );

  @override
  void build() {}

  void setValue(String next) {
    value = next;
  }

  void setSecondaryValue(String next) {
    secondaryValue = next;
  }

  Future<List<({String? label, String error})>> validateAll({
    bool softMode = false,
  }) {
    return processValidators(
      [requiredValidator, secondaryValidator],
      softMode: softMode,
    );
  }
}

final _asyncValidatorHostProvider =
    NotifierProvider<_AsyncValidatorHost, void>(_AsyncValidatorHost.new);

class _AsyncValidatorHost extends Notifier<void> with ValidatorMixin {
  String value = '';
  final List<Completer<String?>> completers = [];
  int asyncValidationCalls = 0;

  late final asyncValidator = createAsyncValidator<String>(
    () => value,
    (state, {required softMode}) async {
      asyncValidationCalls++;
      return completers.removeAt(0).future;
    },
    label: 'async',
  );

  @override
  void build() {}

  void enqueueCompleter(Completer<String?> next) {
    completers.add(next);
  }
}

final _relatedValidatorHostProvider =
    NotifierProvider<_RelatedValidatorHost, void>(_RelatedValidatorHost.new);

class _RelatedValidatorHost extends Notifier<void> with ValidatorMixin {
  String primary = '';
  String related = '';
  int relatedValidatorCalls = 0;

  late final relatedValidator = createValidator<String>(
    () => related,
    (state) {
      relatedValidatorCalls++;
      return state == 'ok' ? null : 'Related error';
    },
    label: 'related',
  );

  late final primaryValidator = createValidator<String>(
    () => primary,
    (state) => state.isEmpty ? 'Primary required' : null,
    label: 'primary',
    relatedValidators: [relatedValidator],
  );

  @override
  void build() {}

  void setPrimary(String next) {
    primary = next;
  }

  void setRelated(String next) {
    related = next;
  }
}

void main() {
  group('SingleValidator', () {
    test('validate sets and clears error', () async {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final notifier = container.read(_syncValidatorHostProvider.notifier);

      expect(notifier.requiredValidator.errorText, isNull);

      expect(notifier.requiredValidator.validate(), 'Required');
      expect(
        container.read(notifier.requiredValidator.errorProvider),
        'Required',
      );

      notifier.setValue('filled');

      expect(notifier.requiredValidator.validate(), isNull);
      expect(container.read(notifier.requiredValidator.errorProvider), isNull);
    });

    test('softValidate does not create a new error from null state', () async {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final notifier = container.read(_syncValidatorHostProvider.notifier);

      expect(notifier.requiredValidator.softValidate(), 'Required');
      expect(container.read(notifier.requiredValidator.errorProvider), isNull);
    });

    test('softValidate updates an existing error', () async {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final notifier = container.read(_syncValidatorHostProvider.notifier);

      expect(notifier.requiredValidator.validate(), 'Required');
      expect(
        container.read(notifier.requiredValidator.errorProvider),
        'Required',
      );

      notifier.setValue('ab');
      notifier.setSecondaryValue('ab');

      expect(notifier.secondaryValidator.validate(), 'Too short');
      expect(
        container.read(notifier.secondaryValidator.errorProvider),
        'Too short',
      );

      notifier.setSecondaryValue('abcd');
      expect(notifier.secondaryValidator.softValidate(), isNull);
      expect(
        container.read(notifier.secondaryValidator.errorProvider),
        isNull,
      );
    });

    test('processValidators returns labels and errors', () async {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final notifier = container.read(_syncValidatorHostProvider.notifier);

      final errors = await notifier.validateAll();

      expect(errors, hasLength(2));
      expect(errors[0], (label: 'value', error: 'Required'));
      expect(errors[1], (label: 'secondary', error: 'Too short'));
    });
  });

  group('SingleAsyncValidator', () {
    test('loadingProvider is true during async validation', () async {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final notifier = container.read(_asyncValidatorHostProvider.notifier);
      final completer = Completer<String?>();
      notifier.enqueueCompleter(completer);

      expect(container.read(notifier.asyncValidator.loadingProvider), isFalse);

      final validationFuture = notifier.asyncValidator.validate();

      await Future<void>.delayed(Duration.zero);
      await container.pump();

      expect(container.read(notifier.asyncValidator.loadingProvider), isTrue);

      completer.complete(null);

      expect(await validationFuture, isNull);
      await container.pump();

      expect(container.read(notifier.asyncValidator.loadingProvider), isFalse);
      expect(notifier.asyncValidationCalls, 1);
    });

    test('loadingProvider stays true until all concurrent validations finish', () async {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final notifier = container.read(_asyncValidatorHostProvider.notifier);
      final firstCompleter = Completer<String?>();
      final secondCompleter = Completer<String?>();
      notifier.enqueueCompleter(firstCompleter);
      notifier.enqueueCompleter(secondCompleter);

      expect(container.read(notifier.asyncValidator.loadingProvider), isFalse);

      final firstFuture = notifier.asyncValidator.validate();
      final secondFuture = notifier.asyncValidator.validate();

      await Future<void>.delayed(Duration.zero);
      await container.pump();

      expect(container.read(notifier.asyncValidator.loadingProvider), isTrue);

      firstCompleter.complete(null);
      expect(await firstFuture, isNull);
      await container.pump();

      expect(container.read(notifier.asyncValidator.loadingProvider), isTrue);

      secondCompleter.complete(null);
      expect(await secondFuture, isNull);
      await container.pump();

      expect(container.read(notifier.asyncValidator.loadingProvider), isFalse);
      expect(notifier.asyncValidationCalls, 2);
    });
  });

  group('Related validators', () {
    test('validate triggers related validator in soft mode', () async {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final notifier = container.read(_relatedValidatorHostProvider.notifier);
      notifier.setPrimary('ok');
      notifier.setRelated('bad');

      expect(container.read(notifier.relatedValidator.errorProvider), isNull);

      expect(notifier.primaryValidator.validate(), isNull);

      expect(notifier.relatedValidatorCalls, 1);
      expect(
        container.read(notifier.relatedValidator.errorProvider),
        isNull,
      );
    });
  });

  group('Provider rebuild', () {
    test('validators keep working after host provider rebuild', () async {
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final sub = container.listen(
        _syncValidatorHostProvider.notifier,
        (_, _) {},
      );
      final notifier = sub.read();

      expect(notifier.requiredValidator.validate(), 'Required');

      // Пересборка провайдера: Ref прошлого build мёртв, notifier и его
      // late final валидаторы - те же самые объекты.
      container.invalidate(_syncValidatorHostProvider);
      await Future<void>.delayed(Duration.zero);

      expect(identical(sub.read(), notifier), isTrue);

      // До ленивого Ref в адаптере здесь бросало UnmountedRefException.
      expect(notifier.requiredValidator.validate(), 'Required');

      notifier.setValue('filled');
      expect(notifier.requiredValidator.validate(), isNull);
      expect(container.read(notifier.requiredValidator.errorProvider), isNull);
    });
  });
}
