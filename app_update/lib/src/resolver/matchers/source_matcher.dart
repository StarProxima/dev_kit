import '../../shared/entities/update_platform.dart';
import '../../shared/entities/update_source.dart';
import '../../shared/models/mergeable.dart';
import '../../shared/models/update_rule/update_rule_config.dart';
import '../../shared/models/update_search/update_search_data.dart';
import '../rule_matcher.dart';

/// Матчер для проверки соответствия источника дистрибуции и платформы
class SourceMatcher extends RuleMatcher {
  const SourceMatcher();

  @override
  bool matches<T extends Mergeable>(
      {required UpdateRuleConfig<T> rule, required UpdateSearchData search}) {
    return _matchBySources(
      rule.sourceIs ?? [UpdateSource.any],
      search.sources,
      search.platform,
    );
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
      if (s.sourceName == target.sourceName) return s;
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
      return globalPlatforms
          .any((p) => p == platform || p == UpdatePlatform.any);
    }
    if (rulePlatforms.isEmpty) return false;
    return rulePlatforms.any((p) => p == platform || p == UpdatePlatform.any);
  }
}
