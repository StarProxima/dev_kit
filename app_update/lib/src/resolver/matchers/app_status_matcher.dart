import '../../shared/entities/app_status.dart';
import '../../shared/models/mergeable.dart';
import '../../shared/models/update_rule/update_rule_config.dart';
import '../../shared/models/update_search/update_search_data.dart';
import '../base/rule_matcher.dart';

/// Матчер для проверки статуса приложения (active, outdated, deprecated и др.)
class AppStatusMatcher extends RuleMatcher {
  const AppStatusMatcher();

  @override
  bool matches<T extends Mergeable>(
      {required UpdateRuleConfig<T> rule, required UpdateSearchData search}) {
    final ruleStatuses = rule.appStatusIs ?? [AppStatus.any];
    final status = search.appStatus;
    return ruleStatuses.contains(AppStatus.any) ||
        ruleStatuses.contains(status);
  }
}
