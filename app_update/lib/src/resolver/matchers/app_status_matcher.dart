import '../../entities/app_status.dart';
import '../../models/update_rule/update_rule_config.dart';
import '../../models/update_search/update_search_data.dart';
import '../base/rule_matcher.dart';

/// Матчер для проверки статуса приложения (active, outdated, deprecated и др.).
class AppStatusMatcher extends RuleMatcher {
  const AppStatusMatcher();

  @override
  bool isMatches({
    required UpdateRuleConfig rule,
    required UpdateSearchData search,
  }) {
    final ruleStatuses = rule.appStatusIs ?? [AppStatus.any];
    final searchStatus = search.appStatus;

    final isMatch = ruleStatuses.contains(AppStatus.any) ||
        ruleStatuses.contains(searchStatus);

    return isMatch;
  }
}
