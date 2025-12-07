import '../../entities/update_platform.dart';
import '../../models/update_rule/update_rule_config.dart';
import '../../models/update_search/update_search_data.dart';
import '../base/rule_matcher.dart';

/// Матчер для проверки соответствия платформы.
class PlatformMatcher extends RuleMatcher {
  const PlatformMatcher();

  @override
  bool isMatches({
    required UpdateRuleConfig rule,
    required UpdateSearchData search,
  }) {
    final ruleStatuses = rule.when?.platformIs ?? [UpdatePlatform.any];
    final searchStatus = search.platform;

    final isMatch = ruleStatuses.contains(UpdatePlatform.any) ||
        ruleStatuses.contains(searchStatus);

    return isMatch;
  }
}
