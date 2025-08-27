import '../../../entities/app_status.dart';
import '../../../entities/update_locale.dart';
import '../../../models/update_content/update_content_config.dart';
import '../../../models/update_rule/update_rule_config.dart';

final defaultEnContentRules = [
  const UpdateRuleConfig(
    localeIs: [UpdateLocale.en, UpdateLocale.any],
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
    appStatusIs: [AppStatus.unsupported],
    localeIs: [UpdateLocale.en, UpdateLocale.any],
    data: UpdateContentConfig(
      title: r'Update $appName',
      description:
          r'Unfortunately, version $appVersion is no longer supported. To continue using the application, update to the latest version. Version $releaseVersion is now available.',
    ),
  ),
];
