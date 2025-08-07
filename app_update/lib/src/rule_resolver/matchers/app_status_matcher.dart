import '../../parser/sub_parsers/update_rule_config/update_rule_config.dart';
import '../../shared/app_status.dart';
import '../models/mergeable.dart';
import '../models/update_search_data.dart';
import 'rule_matcher.dart';

class AppStatusMatcher<T extends Mergeable> implements RuleMatcher<T> {
  const AppStatusMatcher();

  @override
  bool matches({required UpdateRuleConfig<T> rule, required UpdateSearchData search}) {
    final ruleStatuses = rule.appStatuses;
    final status = search.appStatus;
    if (status == null) return true;
    return ruleStatuses.contains(AppStatus.any) || ruleStatuses.contains(status);
  }
}
