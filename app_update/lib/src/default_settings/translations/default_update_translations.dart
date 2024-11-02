import 'dart:ui';

import 'package:collection/collection.dart';

import '../../interpolator/models/update_texts.dart';

class DefaultUpdateTexts extends UpdateTexts {
  const DefaultUpdateTexts.en({
    super.title = '',
    super.description = '',
    super.releaseNotesTitle = '',
    super.releaseNotes = '',
    super.skipButtonText = '',
    super.laterButtonText = '',
    super.updateButtonText = '',
  });

  const DefaultUpdateTexts.ru({
    super.title = r'Обновить $appName?',
    super.description =
        r'Вы можете обновиться до последней версии приложения. Версия $releaseVersion теперь доступна, текущаяя - $appVersion.',
    super.releaseNotesTitle = 'Что нового?',
    super.releaseNotes = '',
    super.skipButtonText = 'Пропустить',
    super.laterButtonText = 'Позже',
    super.updateButtonText = 'Обновить',
  });
}

class DefaultUpdateTranslations extends UpdateTranslations {
  static final _instance = DefaultUpdateTranslations._internal();

  static final _defaultTranslations = UnmodifiableMapView(<Locale, UpdateTexts>{
    const Locale('en'): const DefaultUpdateTexts.en(),
    const Locale('ru'): const DefaultUpdateTexts.ru(),
  });

  factory DefaultUpdateTranslations.base() => _instance;

  DefaultUpdateTranslations._internal() : super(_defaultTranslations);

  DefaultUpdateTranslations.merge(
    Map<Locale, UpdateTexts> translations,
  ) : super(
          {..._defaultTranslations, ...translations},
        );
}
