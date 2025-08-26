import 'package:pub_semver/pub_semver.dart';

import '../../shared/entities/update_version_constraint.dart';
import '../../shared/models/mergeable.dart';
import '../../shared/models/update_rule/update_rule_config.dart';
import '../../shared/models/update_search/update_search_data.dart';
import '../rule_matcher.dart';

/// Матчер для проверки соответствия версии приложения semver-ограничениям
class VersionMatcher implements RuleMatcher {
  const VersionMatcher();

  @override
  bool matches<T extends Mergeable>(
      {required UpdateRuleConfig<T> rule, required UpdateSearchData search}) {
    final constraints = rule.versionIs ?? [UpdateVersionConstraint.any];
    if (constraints.contains(UpdateVersionConstraint.any)) return true;
    final Version local = search.localVersion;
    for (final c in constraints) {
      final vc = c.versionConstraint;
      if (vc != null && vc.allows(local)) return true;
    }
    return false;
  }
}
