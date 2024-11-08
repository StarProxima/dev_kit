// ignore_for_file: avoid-missing-enum-constant-in-map

import 'dart:ui';

import '../../interpolator/models/update_texts.dart';
import '../../shared/update_alert_type.dart';
import '../../shared/update_text_container.dart';
import '../../shared/version_status.dart';
import 'locales/en_translations.dart';
import 'locales/ru_translations.dart';

class DefaultUpdateTextContainer extends UpdateTextContainer {
  static final _defaultText = {
    const Locale('base'): const EnUpdateTranslations().translations(),
    const Locale('en'): const EnUpdateTranslations().translations(),
    const Locale('ru'): const RuUpdateTranslations().translations(),
  };

  DefaultUpdateTextContainer() : super(_defaultText);

  DefaultUpdateTextContainer.merge(
    Map<Locale, Map<UpdateAlertTypeBase, Map<VersionStatusBase, UpdateText>>> text,
  ) : super(
          {..._defaultText, ...text},
        );
}

abstract class UpdateTranslations {
  const UpdateTranslations();

  Map<UpdateAlertTypeBase, Map<VersionStatusBase, UpdateText>> translations();
}
