import '../../entities/update_view_target.dart';
import '../../models/update_rule/update_rule_config.dart';
import '../../models/update_search/update_search_data.dart';
import '../base/rule_matcher.dart';

/// Матчер для проверки соответствия целевого UI-элемента (card, dialog, screen и др.).
class ViewTargetMatcher extends RuleMatcher {
  const ViewTargetMatcher();

  @override
  bool isMatches({
    required UpdateRuleConfig rule,
    required UpdateSearchData search,
  }) {
    final ruleTargets = rule.when?.viewTargetIs ?? [UpdateViewTarget.any];
    final searchTarget = search.displayTarget;

    final isMatch = ruleTargets.contains(UpdateViewTarget.any) ||
        ruleTargets.contains(searchTarget);

    return isMatch;
  }
}
