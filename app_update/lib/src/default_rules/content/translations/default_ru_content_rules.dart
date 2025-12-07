import '../../../entities/app_status.dart';
import '../../../entities/update_locale.dart';
import '../../../models/update_content/update_content_config.dart';
import '../../../models/update_rule/update_rule_config.dart';
import '../../../models/update_rule/update_rule_when.dart';

// ignore: prefer-static-class
final defaultRuContentRules = [
  const UpdateRuleConfig(
    when: UpdateRuleWhen(
      localeIs: [UpdateLocale.ru],
    ),
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
      customParams: null,
    ),
  ),
  const UpdateRuleConfig(
    when: UpdateRuleWhen(
      appStatusIs: [AppStatus.unsupported],
      localeIs: [UpdateLocale.ru],
    ),
    data: UpdateContentConfig(
      title: r'Обновите $appName',
      description:
          r'К сожалению, версия $appVersion больше не поддерживается. Чтобы продолжить использовать приложение, обновитесь до последней версии. Версия $releaseVersion теперь доступна.',
    ),
  ),
];
