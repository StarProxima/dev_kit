import '../../parser/sub_parsers/update_rule_config/update_rule_config.dart';
import '../../shared/update_date.dart';
import '../models/mergeable.dart';
import '../models/update_search_data.dart';
import 'rule_matcher.dart';

class TemporalMatcher<T extends Mergeable> implements RuleMatcher<T> {
  const TemporalMatcher();

  @override
  bool matches({required UpdateRuleConfig<T> rule, required UpdateSearchData search}) {
    return _matchByDateAndRollout(
      ruleDate: rule.date,
      delay: rule.delay,
      rollout: rule.rollout,
      segmentationPercent: rule.segmentationPercent,
      currentDate: search.currentDate,
      localReleaseDate: search.localReleaseDate,
      updateReleaseDate: search.updateReleaseDate,
      rolloutPointer: search.rolloutPointer,
      segmentationPointer: search.segmentationPointer,
    );
  }

  bool _matchByDateAndRollout({
    required UpdateDate ruleDate,
    required Duration? delay,
    required Duration? rollout,
    required double? segmentationPercent,
    required DateTime currentDate,
    required DateTime? localReleaseDate,
    required DateTime? updateReleaseDate,
    required double rolloutPointer,
    required double segmentationPointer,
  }) {
    if (segmentationPercent != null) {
      final threshold = segmentationPercent.clamp(0, 100) / 100.0;
      if (segmentationPointer > threshold) return false;
    }

    final hasTemporalConditions = delay != null || rollout != null;
    if (ruleDate == UpdateDate.any && !hasTemporalConditions) return true;

    DateTime? baseDate = ruleDate.date;
    if (baseDate == null && ruleDate != UpdateDate.any) {
      if (ruleDate == UpdateDate.localReleaseDate) {
        baseDate = localReleaseDate;
      } else if (ruleDate == UpdateDate.updateReleaseDate) {
        baseDate = updateReleaseDate;
      }
    }

    if (!hasTemporalConditions) {
      return baseDate != null &&
          (currentDate.isAfter(baseDate) || currentDate.isAtSameMomentAs(baseDate));
    }

    if (baseDate == null) return false;

    if (delay != null) {
      final start = baseDate.add(delay);
      if (currentDate.isBefore(start)) return false;
    }

    if (rollout != null) {
      final elapsed = currentDate.difference(baseDate);
      if (elapsed.isNegative) return false;
      final totalMs = rollout.inMilliseconds;
      if (totalMs <= 0) return false;
      final fraction = (elapsed.inMilliseconds / totalMs).clamp(0.0, 1.0);
      if (rolloutPointer > fraction) return false;
    }

    return true;
  }
}
