import '../../parser/sub_parsers/update_rule_config/update_rule_config.dart';
import '../../shared/update_platform.dart';
import '../../shared/update_source.dart';
import '../models/mergeable.dart';
import '../models/rule_matcher.dart';
import '../models/update_search_data.dart';

class SourceMatcher<T extends Mergeable> implements RuleMatcher<T> {
  const SourceMatcher();

  @override
  bool matches({required UpdateRuleConfig<T> rule, required UpdateSearchData search}) {
    return _matchBySources(rule.sources, search.sources, search.platform);
  }

  bool _matchBySources(
    List<UpdateSource> ruleSources,
    List<UpdateSource> searchSources,
    UpdatePlatform platform,
  ) {
    if (ruleSources.contains(UpdateSource.any)) return true;
    for (final ruleSource in ruleSources) {
      final matchedSearchSource = _findSource(searchSources, ruleSource);
      if (matchedSearchSource == null) continue;
      if (_sourceSupportsPlatform(ruleSource, platform, matchedSearchSource)) {
        return true;
      }
    }
    return false;
  }

  UpdateSource? _findSource(List<UpdateSource> sources, UpdateSource target) {
    for (final s in sources) {
      if (s == target) return s;
    }
    return null;
  }

  bool _sourceSupportsPlatform(
    UpdateSource ruleSource,
    UpdatePlatform platform,
    UpdateSource searchSource,
  ) {
    final rulePlatforms = ruleSource.platforms;
    if (rulePlatforms == null) {
      final globalPlatforms = searchSource.platforms;
      if (globalPlatforms == null || globalPlatforms.isEmpty) return true;
      return globalPlatforms.any((p) => p == platform || p == UpdatePlatform.any);
    }
    if (rulePlatforms.isEmpty) return false;
    return rulePlatforms.any((p) => p == platform || p == UpdatePlatform.any);
  }
}
