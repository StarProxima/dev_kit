import '../../entities/update_version_constraint.dart';
import '../../models/update_rule/update_rule_config.dart';
import '../../models/update_search/update_search_data.dart';
import '../base/rule_matcher.dart';

/// Матчер для проверки соответствия версии приложения semver-ограничениям.
class VersionMatcher extends RuleMatcher {
  const VersionMatcher();

  @override
  bool isMatches({
    required UpdateRuleConfig rule,
    required UpdateSearchData search,
  }) {
    final constraints = rule.appVersionIs ?? [UpdateVersionConstraint.any];
    if (constraints.contains(UpdateVersionConstraint.any)) return true;
    final local = search.appVersion;
    for (final c in constraints) {
      final vc = c.versionConstraint;
      if (vc != null && vc.allows(local)) return true;
    }

    return false;
  }
}
