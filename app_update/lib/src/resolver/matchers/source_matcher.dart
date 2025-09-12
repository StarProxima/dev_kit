import '../../entities/update_platform.dart';
import '../../entities/update_source.dart';
import '../../models/update_rule/update_rule_config.dart';
import '../../models/update_search/update_search_data.dart';
import '../base/rule_matcher.dart';

/// Матчер для проверки соответствия источника дистрибуции и платформы.
class SourceMatcher extends RuleMatcher {
  const SourceMatcher();

  @override
  bool isMatches({
    required UpdateRuleConfig rule,
    required UpdateSearchData search,
  }) {
    return isMatchBySources(
      ruleSources: rule.sourceIs ?? [UpdateSource.any],
      searchSources: search.sources,
      searchPlatform: search.platform,
    );
  }

  bool isMatchBySources({
    required List<UpdateSource> ruleSources,
    required List<UpdateSource> searchSources,
    required UpdatePlatform searchPlatform,
  }) {
    if (ruleSources.contains(UpdateSource.any)) return true;
    if (searchSources.contains(UpdateSource.any)) return true;

    for (final ruleSource in ruleSources) {
      final matchedSearchSource = _findSource(searchSources, ruleSource);
      if (matchedSearchSource == null) continue;
      if (_isSourceSupportsPlatform(
        ruleSource,
        searchPlatform,
        matchedSearchSource,
      )) {
        return true;
      }
    }

    return false;
  }

  static UpdateSource? _findSource(
    List<UpdateSource> sources,
    UpdateSource target,
  ) {
    for (final s in sources) {
      if (s.sourceName == target.sourceName) return s;
    }

    return null;
  }

  static bool _isSourceSupportsPlatform(
    UpdateSource ruleSource,
    UpdatePlatform searchPlatform,
    UpdateSource searchSource,
  ) {
    final rulePlatforms = ruleSource.platforms ?? searchSource.platforms;

    if (rulePlatforms == null) {
      /// Если null, то считаем, что правило не учитывает платформы
      if (searchSource.platforms == null) return true;
      return false;
    }

    final isMatch = rulePlatforms.contains(UpdatePlatform.any) ||
        rulePlatforms.contains(searchPlatform);

    return isMatch;
  }
}
