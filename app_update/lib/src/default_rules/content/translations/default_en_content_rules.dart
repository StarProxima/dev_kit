import '../../../shared/models/update_content/update_content_config.dart';
import '../../../shared/models/update_rule/update_rule_config.dart';
import '../../../shared/update_entities/app_status.dart';
import '../../../shared/update_entities/update_locale.dart';

final List<UpdateRuleConfig<UpdateContentConfig>> defaultEnContentRules = [
  const UpdateRuleConfig(
    locales: [UpdateLocale.en, UpdateLocale.any],
    data: UpdateContentConfig.byRequired(
      updateUrl: null,
      title: r'Update $appName',
      description:
          r'You can update to the latest version of the application. Version $releaseVersion is now available, current - $appVersion.',
      releaseNotesTitle: "What's new?",
      releaseNotes: null,
      skipButton: 'Skip',
      postponeButton: 'Later',
      updateButton: 'Update',
      customData: null,
    ),
  ),
  const UpdateRuleConfig(
    locales: [UpdateLocale.en, UpdateLocale.any],
    appStatuses: [AppStatus.unsupported],
    data: UpdateContentConfig(
      title: r'Update $appName',
      description:
          r'Unfortunately, version $appVersion is no longer supported. To continue using the application, update to the latest version. Version $releaseVersion is now available.',
    ),
  ),
];
