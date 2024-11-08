// ignore_for_file

// ignore_for_file: avoid-missing-enum-constant-in-map

import '../../../interpolator/models/update_texts.dart';
import '../../../shared/update_alert_type.dart';
import '../../../shared/version_status.dart';
import '../default_update_text_container.dart';

class EnUpdateTranslations extends UpdateTranslations {
  const EnUpdateTranslations();

  @override
  Map<UpdateAlertTypeBase, Map<VersionStatusBase, UpdateText>> translations() {
    const baseTexts = UpdateText(
      title: r'Обновите $appName',
      description:
          r'Вы можете обновиться до последней версии приложения. Версия $releaseVersion теперь доступна, текущаяя - $appVersion.',
      releaseNotesTitle: 'Что нового?',
      releaseNotes: '',
      skipButton: 'Пропустить',
      laterButton: 'Позже',
      updateButton: 'Обновить',
    );

    return {
      UpdateAlertTypeBase.base: {
        VersionStatusBase.base: baseTexts,
        VersionStatusBase.unsupported: baseTexts.copyWith(
          title: r'Обновите $appName',
          description:
              r'Чтобы продолжить пользоваться приложением, обновите его до последней версии. Версия $releaseVersion теперь доступна, текущая - $appVersion.',
        ),
        VersionStatusBase.deprecated: baseTexts.copyWith(
          title: r'Обновите $appName',
          description:
              r'Текущая версия приложения устарала и скоро перестанет поддерживаться, обновите его до последней версии. Версия $releaseVersion теперь доступна, текущая - $appVersion.',
        ),
      },
      UpdateAlertTypeBase.card: {
        VersionStatusBase.base: baseTexts.copyWith(
          title: r'Обновите $appName',
          description: 'Дайте ему возможность стать лучше!',
        ),
      },
    };
  }
}
