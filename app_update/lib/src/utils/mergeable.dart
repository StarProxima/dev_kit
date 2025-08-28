// ignore_for_file: prefer-named-parameters

import '../models/update_rule/update_rule_config.dart';

abstract class Mergeable<T extends Mergeable<T>> {
  T merge(T other);

  static Map<String, dynamic>? mergecustomParams(
    Map<String, dynamic>? customParams1,
    Map<String, dynamic>? customParams2, [
    Map<String, dynamic>? customParams3,
    Map<String, dynamic>? customParams4,
    Map<String, dynamic>? customParams5,
  ]) {
    final customParams = {
      ...?customParams1,
      ...?customParams2,
      ...?customParams3,
      ...?customParams4,
      ...?customParams5,
    };

    return customParams.isNotEmpty ? customParams : null;
  }

  static List<UpdateRuleConfig<T>>? mergeRules<T extends Mergeable<T>>(
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
