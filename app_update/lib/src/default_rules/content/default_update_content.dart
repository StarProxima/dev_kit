import '../../models/update_content/update_content_config.dart';
import '../../models/update_rule/update_rule_config.dart';
import 'translations/default_en_content_rules.dart';
import 'translations/default_ru_content_rules.dart';

final List<UpdateRuleConfig<UpdateContentConfig>> defaultUpdateContentRules = [
  ...defaultEnContentRules,
  ...defaultRuContentRules,
];
