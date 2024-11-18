// ignore_for_file

// ignore_for_file: avoid-missing-enum-constant-in-map

import '../../../linker/models/update_text_data.dart';
import '../../../shared/update_alert_type.dart';
import '../../../shared/version_status.dart';
import '../default_update_text_container.dart';

// TODO: Перевести на английский
class EnUpdateTranslations extends UpdateTranslations {
  static const tr = {
    UpdateAlertTypeBase.base: {
      VersionStatusBase.base: UpdateTextData.byRequired(
        title: r'Обновите $appName',
        description:
            r'Вы можете обновиться до последней версии приложения. Версия $releaseVersion теперь доступна, текущаяя - $appVersion.',
        releaseNotesTitle: 'Что нового?',
        releaseNotes: '',
        skipButton: 'Пропустить',
        laterButton: 'Позже',
        updateButton: 'Обновить',
        customData: null,
      ),
      VersionStatusBase.unsupported: UpdateTextData(
        title: r'Обновите $appName',
        description:
            r'Чтобы продолжить пользоваться приложением, обновите его до последней версии. Версия $releaseVersion теперь доступна, текущая - $appVersion.',
      ),
      VersionStatusBase.deprecated: UpdateTextData(
        title: r'Обновите $appName',
        description:
            r'Текущая версия приложения устарала и скоро перестанет поддерживаться, обновите его до последней версии. Версия $releaseVersion теперь доступна, текущая - $appVersion.',
      ),
    },
    UpdateAlertTypeBase.card: {
      VersionStatusBase.base: UpdateTextData(
        title: r'Обновите $appName',
        description: 'Дайте ему возможность стать лучше!',
      ),
    },
  };

  const EnUpdateTranslations() : super(tr);
}
