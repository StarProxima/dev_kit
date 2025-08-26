import '../../../shared/models/update_content/update_content_config.dart';
import '../../../shared/models/update_rule/update_rule_config.dart';
import '../../../shared/update_entities/app_status.dart';
import '../../../shared/update_entities/update_locale.dart';

final List<UpdateRuleConfig<UpdateContentConfig>> defaultRuContentRules = [
  const UpdateRuleConfig(
    locales: [UpdateLocale.ru],
    data: UpdateContentConfig.byRequired(
      updateUrl: null,
      title: r'Обновите $appName',
      description:
          r'Вы можете обновиться до последней версии приложения. Версия $releaseVersion теперь доступна, текущаяя - $appVersion.',
      releaseNotesTitle: 'Что нового?',
      releaseNotes: null,
      skipButton: 'Пропустить',
      postponeButton: 'Позже',
      updateButton: 'Обновить',
      customData: null,
    ),
  ),
  const UpdateRuleConfig(
    locales: [UpdateLocale.ru],
    appStatuses: [AppStatus.unsupported],
    data: UpdateContentConfig(
      title: r'Обновите $appName',
      description:
          r'К сожалению, версия $appVersion больше не поддерживается. Чтобы продолжить использовать приложение, обновитесь до последней версии. Версия $releaseVersion теперь доступна.',
    ),
  ),
];
