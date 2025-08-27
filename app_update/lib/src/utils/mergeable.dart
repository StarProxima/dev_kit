import '../models/update_rule/update_rule_config.dart';

abstract class Mergeable {
  Mergeable merge(Mergeable other);

  static Map<String, dynamic>? mergeCustomData(
    Map<String, dynamic>? customData1,
    Map<String, dynamic>? customData2, [
    Map<String, dynamic>? customData3,
    Map<String, dynamic>? customData4,
    Map<String, dynamic>? customData5,
  ]) {
    final customData = {
      ...?customData1,
      ...?customData2,
      ...?customData3,
      ...?customData4,
      ...?customData5,
    };

    return customData.isNotEmpty ? customData : null;
  }

  static List<UpdateRuleConfig<T>>? mergeRules<T extends Mergeable>(
    List<UpdateRuleConfig<T>>? rules1,
    List<UpdateRuleConfig<T>>? rules2, [
    List<UpdateRuleConfig<T>>? rules3,
    List<UpdateRuleConfig<T>>? rules4,
    List<UpdateRuleConfig<T>>? rules5,
  ]) {
    final rules = [
      ...?rules1,
      ...?rules2,
      ...?rules3,
      ...?rules4,
      ...?rules5,
    ];

    return rules.isNotEmpty ? rules : null;
  }
}
