import 'dart:ui';

import 'package:collection/collection.dart';

import '../../interpolator/models/update_texts.dart';

class DefaultUpdateTexts extends UpdateText {
  const DefaultUpdateTexts.en({
    super.title = '',
    super.description = '',
    super.releaseNotesTitle = '',
    super.releaseNotes = '',
    super.skipButton = '',
    super.laterButton = '',
    super.updateButton = '',
  });

  const DefaultUpdateTexts.ru({
    super.title = r'Обновить $appName?',
    super.description =
        r'Вы можете обновиться до последней версии приложения. Версия $releaseVersion теперь доступна, текущаяя - $appVersion.',
    super.releaseNotesTitle = 'Что нового?',
    super.releaseNotes = '',
    super.skipButton = 'Пропустить',
    super.laterButton = 'Позже',
    super.updateButton = 'Обновить',
  });
}

// class DefaultUpdateTranslations extends UpdateTranslations {
//   static final _instance = DefaultUpdateTranslations._internal();

//   static final _defaultTranslations = UnmodifiableMapView(<Locale, UpdateText>{
//     const Locale('en'): const DefaultUpdateTexts.en(),
//     const Locale('ru'): const DefaultUpdateTexts.ru(),
//   });

//   factory DefaultUpdateTranslations.base() => _instance;

//   DefaultUpdateTranslations._internal() : super(_defaultTranslations);

//   DefaultUpdateTranslations.merge(
//     Map<Locale, UpdateText> translations,
//   ) : super(
//           {..._defaultTranslations, ...translations},
//         );
// }
