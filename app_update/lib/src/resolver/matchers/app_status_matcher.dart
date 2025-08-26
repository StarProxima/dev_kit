import '../../shared/models/mergeable.dart';
import '../../shared/models/update_rule/update_rule_config.dart';
import '../../shared/models/update_search/update_search_data.dart';
import '../../shared/update_entities/app_status.dart';
import 'rule_matcher.dart';

class AppStatusMatcher<T extends Mergeable> implements RuleMatcher<T> {
  const AppStatusMatcher();

  @override
  bool matches({required UpdateRuleConfig<T> rule, required UpdateSearchData search}) {
    final ruleStatuses = rule.appStatuses ?? [AppStatus.any];
    final status = search.appStatus;
    return ruleStatuses.contains(AppStatus.any) || ruleStatuses.contains(status);
  }
}
