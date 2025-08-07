import '../../parser/sub_parsers/update_rule_config/update_rule_config.dart';
import '../../shared/update_view_target.dart';
import '../models/mergeable.dart';
import '../models/update_search_data.dart';
import 'rule_matcher.dart';

class ViewTargetMatcher<T extends Mergeable> implements RuleMatcher<T> {
  const ViewTargetMatcher();

  @override
  bool matches({required UpdateRuleConfig<T> rule, required UpdateSearchData search}) {
    final targets = rule.viewTargets;
    final target = search.displayTarget;
    return targets.contains(UpdateViewTarget.any) || targets.contains(target);
  }
}
