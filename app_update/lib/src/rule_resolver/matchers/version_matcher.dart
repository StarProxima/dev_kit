import 'package:pub_semver/pub_semver.dart';

import '../../shared/mergeable.dart';
import '../../shared/models/update_rule/update_rule_config.dart';
import '../../shared/models/update_search/update_search_data.dart';
import '../../shared/update_entities/update_version_constraint.dart';
import 'rule_matcher.dart';

class VersionMatcher<T extends Mergeable> implements RuleMatcher<T> {
  const VersionMatcher();

  @override
  bool matches({required UpdateRuleConfig<T> rule, required UpdateSearchData search}) {
    final constraints = rule.versions ?? [UpdateVersionConstraint.any];
    if (constraints.contains(UpdateVersionConstraint.any)) return true;
    final Version local = search.localVersion;
    for (final c in constraints) {
      final vc = c.versionConstraint;
      if (vc != null && vc.allows(local)) return true;
    }
    return false;
  }
}
