import '../../entities/update_view_target.dart';
import '../../utils/mergeable.dart';
import '../../models/update_rule/update_rule_config.dart';
import '../../models/update_search/update_search_data.dart';
import '../base/rule_matcher.dart';

/// Матчер для проверки соответствия целевого UI-элемента (card, dialog, screen и др.)
class ViewTargetMatcher extends RuleMatcher {
  const ViewTargetMatcher();

  @override
  bool matches<T extends Mergeable>(
      {required UpdateRuleConfig<T> rule, required UpdateSearchData search}) {
    final targets = rule.viewTargetIs ?? [UpdateViewTarget.any];
    final target = search.displayTarget;
    return targets.contains(UpdateViewTarget.any) || targets.contains(target);
  }
}
