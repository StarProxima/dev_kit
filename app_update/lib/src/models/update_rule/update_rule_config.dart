import '../../utils/mergeable.dart';
import 'update_rule_rollout.dart';
import 'update_rule_when.dart';

class UpdateRuleConfig<T extends Mergeable<T>> {
  final UpdateRuleWhen? when;
  final UpdateRuleRollout? rollout;
  final T data;

  const UpdateRuleConfig({
    this.when,
    this.rollout,
    required this.data,
  });

  const UpdateRuleConfig.byRequired({
    required this.when,
    required this.rollout,
    required this.data,
  });

  UpdateRuleConfig<T> copyWith({
    UpdateRuleWhen? when,
    UpdateRuleRollout? rollout,
    T? data,
  }) =>
      UpdateRuleConfig(
        when: when ?? this.when,
        rollout: rollout ?? this.rollout,
        data: data ?? this.data,
      );
}
