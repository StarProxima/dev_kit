import '../../entities/update_source.dart';
import '../../models/update_content/update_content_config.dart';
import '../../models/update_rule/update_rule_config.dart';

// ignore: prefer-static-class
final defaultSourceUrlUpdateContent = [
  UpdateRuleConfig(
    sourceIs: [UpdateSource.googlePlay],
    data: UpdateContentConfig(
      updateUrl: Uri.parse(
        r'https://play.google.com/store/apps/details?id=${appPackageName}',
      ),
    ),
  ),
  UpdateRuleConfig(
    sourceIs: [UpdateSource.ruStore],
    data: UpdateContentConfig(
      updateUrl: Uri.parse(
        r'https://apps.rustore.ru/app/${appPackageName}',
      ),
    ),
  ),
];
