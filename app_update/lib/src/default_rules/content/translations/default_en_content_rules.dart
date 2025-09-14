import '../../../entities/app_status.dart';
import '../../../entities/update_locale.dart';
import '../../../models/update_content/update_content_config.dart';
import '../../../models/update_rule/update_rule_config.dart';
import '../../../models/update_rule/update_rule_when.dart';

// ignore: prefer-static-class
final defaultEnContentRules = [
  const UpdateRuleConfig(
    when: UpdateRuleWhen(
      localeIs: [UpdateLocale.en, UpdateLocale.any],
    ),
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
      customParams: null,
    ),
  ),
  const UpdateRuleConfig(
    when: UpdateRuleWhen(
      appStatusIs: [AppStatus.unsupported],
      localeIs: [UpdateLocale.en, UpdateLocale.any],
    ),
    data: UpdateContentConfig(
      title: r'Update $appName',
      description:
          r'Unfortunately, version $appVersion is no longer supported. To continue using the application, update to the latest version. Version $releaseVersion is now available.',
    ),
  ),
];
