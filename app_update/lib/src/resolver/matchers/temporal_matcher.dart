import '../../entities/update_date.dart';
import '../../models/update_rule/update_rule_config.dart';
import '../../models/update_search/update_search_data.dart';
import '../base/rule_matcher.dart';

/// Матчер для проверки временных условий: date, delay, rollout, segmentation.
class TemporalMatcher extends RuleMatcher {
  const TemporalMatcher();

  @override
  bool isMatches({
    required UpdateRuleConfig rule,
    required UpdateSearchData search,
  }) {
    final rolloutParams = rule.rollout;

    return _isMatchByDateAndRollout(
      ruleDate: rolloutParams?.date ?? UpdateDate.any,
      delay: rolloutParams?.delay,
      rollout: rolloutParams?.gradualRolloutDuration,
      userSegmentationPercent: rolloutParams?.userSegmentationPercent,
      currentDate: search.currentDate,
      localReleaseDate: search.localReleaseDate,
      updateReleaseDate: search.updateReleaseDate,
      appUpdateDate: search.appUpdateDate,
      appInstallDate: search.appInstallDate,
      rolloutPointer: search.rolloutPointer,
      userSegmentationPointer: search.userSegmentationPointer,
    );
  }

  // ignore: avoid-long-parameter-list
  static bool _isMatchByDateAndRollout({
    required UpdateDate ruleDate,
    required Duration? delay,
    required Duration? rollout,
    required double? userSegmentationPercent,
    required DateTime currentDate,
    required DateTime? localReleaseDate,
    required DateTime? updateReleaseDate,
    required DateTime? appUpdateDate,
    required DateTime? appInstallDate,
    required double rolloutPointer,
    required double userSegmentationPointer,
  }) {
    if (userSegmentationPercent != null) {
      final threshold = userSegmentationPercent.clamp(0, 100) / 100.0;
      if (userSegmentationPointer > threshold) return false;
    }

    if (ruleDate == UpdateDate.any) return true;

    DateTime? baseDate = ruleDate.date;

    baseDate ??= switch (ruleDate) {
      UpdateDate.localReleaseDate => localReleaseDate,
      UpdateDate.updateReleaseDate => updateReleaseDate,
      UpdateDate.appUpdateDate => appUpdateDate,
      UpdateDate.appInstallDate => appInstallDate,
      _ => null,
    };

    if (baseDate == null) return false;

    if (delay != null) {
      baseDate = baseDate.add(delay);
    }

    if (currentDate.isBefore(baseDate)) return false;

    if (rollout != null) {
      final elapsed = currentDate.difference(baseDate);
      final fraction =
          (elapsed.inMilliseconds / rollout.inMilliseconds).clamp(0.0, 1.0);
      if (rolloutPointer > fraction) return false;
    }

    return true;
  }
}
