// ignore_for_file: avoid-missing-enum-constant-in-map

import 'dart:ui';

import '../../linker/models/update_text_data.dart';
import '../../linker/models/update_text_data_container.dart';
import '../../shared/update_alert_type.dart';
import '../../shared/version_status.dart';
import 'locales/en_translations.dart';
import 'locales/ru_translations.dart';

class DefaultUpdateTextDataContainer extends UpdateTextDataContainer {
  static final _defaultText = {
    const Locale('base'): const EnUpdateTranslations().translations(),
    const Locale('en'): const EnUpdateTranslations().translations(),
    const Locale('ru'): const RuUpdateTranslations().translations(),
  };

  DefaultUpdateTextDataContainer() : super(_defaultText);
}

abstract class UpdateTranslations {
  const UpdateTranslations();

  Map<UpdateAlertTypeBase, Map<VersionStatusBase, UpdateTextData>> translations();
}
