import '../../entities/update_source.dart';
import '../../models/update_content/update_content_config.dart';
import '../../models/update_rule/update_rule_config.dart';
import '../../models/update_rule/update_rule_when.dart';

// ignore: prefer-static-class, prefer-prefixed-global-constants
const defaultSourceUrlUpdateContent = [
  UpdateRuleConfig(
    when: UpdateRuleWhen(
      sourceIs: [UpdateSource.googlePlay],
    ),
    data: UpdateContentConfig(
      updateUrl:
          r'https://play.google.com/store/apps/details?id=${appPackageName}',
    ),
  ),
  UpdateRuleConfig(
    when: UpdateRuleWhen(
      sourceIs: [UpdateSource.ruStore],
    ),
    data: UpdateContentConfig(
      updateUrl: r'https://apps.rustore.ru/app/${appPackageName}',
    ),
  ),
];
