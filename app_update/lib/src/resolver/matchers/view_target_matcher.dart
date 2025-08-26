import '../../shared/entities/update_view_target.dart';
import '../../shared/models/mergeable.dart';
import '../../shared/models/update_rule/update_rule_config.dart';
import '../../shared/models/update_search/update_search_data.dart';
import 'rule_matcher.dart';

class ViewTargetMatcher<T extends Mergeable> implements RuleMatcher<T> {
  const ViewTargetMatcher();

  @override
  bool matches(
      {required UpdateRuleConfig<T> rule, required UpdateSearchData search}) {
    final targets = rule.viewTargets ?? [UpdateViewTarget.any];
    final target = search.displayTarget;
    return targets.contains(UpdateViewTarget.any) || targets.contains(target);
  }
}
