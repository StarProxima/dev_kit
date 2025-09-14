// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment, avoid-long-functions

import '../../models/update_rule/update_rule_config.dart';
import '../../utils/mergeable.dart';
import '../parse_config_exeption.dart';
import 'update_rule_rollout_parser.dart';
import 'update_rule_when_parser.dart';

class UpdateRuleConfigParser {
  static const _whenParser = UpdateRuleWhenParser();
  static const _rolloutParser = UpdateRuleRolloutParser();

  const UpdateRuleConfigParser();

  UpdateRuleConfig<T>? parse<T extends Mergeable<T>>(
    Object? value, {
    required T? Function(Object? value) dataParser,
    required bool isDebug,
  }) {
    if (value == null) return null;

    if (value is! Map) {
      throw ParseConfigException.wrongType(
        rightType: Map,
        wrongType: value.runtimeType,
        parserType: UpdateRuleConfigParser,
        configs: [value],
      );
    }

    final map = Map<String, dynamic>.from(value);

    // when section
    final whenValue = map.remove('when');
    final when = _whenParser.parse(whenValue, isDebug: isDebug);

    // rollout section
    final rolloutValue = map.remove('rollout');
    final rollout = _rolloutParser.parse(rolloutValue, isDebug: isDebug);

    // data section
    final dataValue = map.remove('data');
    final data = dataParser(dataValue);

    if (data == null) {
      try {
        // if not exists, use rule itself as data
        final finalData = dataParser(map);

        if (finalData == null) {
          throw ParseConfigException.requiredParams(
            params: ['data'],
            parserType: UpdateRuleConfigParser,
            configs: [value],
          );
        }

        return UpdateRuleConfig<T>(
          when: when,
          rollout: rollout,
          data: finalData,
        );
      } on ParseConfigException catch (_) {
        throw ParseConfigException.requiredParams(
          params: ['data'],
          parserType: UpdateRuleConfigParser,
          configs: [value],
        );
      }
    }

    // Check for unexpected params
    if (isDebug && map.isNotEmpty) {
      throw ParseConfigException.unexpectedParams(
        params: map,
        parserType: UpdateRuleConfigParser,
        configs: [value],
      );
    }

    return UpdateRuleConfig<T>(
      when: when,
      rollout: rollout,
      data: data,
    );
  }
}
