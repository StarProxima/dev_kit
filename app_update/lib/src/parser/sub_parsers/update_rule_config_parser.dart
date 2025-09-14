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

    // Check if this is new format (has when/rollout sections)
    final hasWhenSection = map.containsKey('when');
    final hasRolloutSection = map.containsKey('rollout');

    if (hasWhenSection || hasRolloutSection) {
      // New format: when/rollout/data
      return _parseNewFormat(map, dataParser, isDebug);
    } else {
      // Legacy format: flat structure - convert to new format
      return _parseLegacyFormat(map, dataParser, isDebug);
    }
  }

  UpdateRuleConfig<T>? _parseNewFormat<T extends Mergeable<T>>(
    Map<String, dynamic> map,
    T? Function(Object? value) dataParser,
    bool isDebug,
  ) {
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
            configs: [map],
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
          configs: [map],
        );
      }
    }

    // Check for unexpected params
    if (isDebug && map.isNotEmpty) {
      throw ParseConfigException.unexpectedParams(
        params: map,
        parserType: UpdateRuleConfigParser,
        configs: [map],
      );
    }

    return UpdateRuleConfig<T>(
      when: when,
      rollout: rollout,
      data: data,
    );
  }

  UpdateRuleConfig<T>? _parseLegacyFormat<T extends Mergeable<T>>(
    Map<String, dynamic> map,
    T? Function(Object? value) dataParser,
    bool isDebug,
  ) {
    // Extract legacy when fields
    final legacyWhenFields = <String, dynamic>{};
    final whenFieldNames = [
      'app_status_is',
      'locale_is',
      'view_target_is',
      'app_version_is',
      'source_is',
      'platform_is',
      'custom_params'
    ];

    for (final field in whenFieldNames) {
      final value = map.remove(field);
      if (value != null) {
        legacyWhenFields[field] = value;
      }
    }

    // Extract legacy rollout fields
    final legacyRolloutFields = <String, dynamic>{};
    final rolloutFieldNames = [
      'date',
      'delay_hours',
      'gradual_rollout_hours',
      'user_segmentation_percent'
    ];

    for (final field in rolloutFieldNames) {
      final value = map.remove(field);
      if (value != null) {
        legacyRolloutFields[field] = value;
      }
    }

    // Parse when and rollout from legacy fields
    final when = legacyWhenFields.isNotEmpty
        ? _whenParser.parse(legacyWhenFields, isDebug: isDebug)
        : null;
    final rollout = legacyRolloutFields.isNotEmpty
        ? _rolloutParser.parse(legacyRolloutFields, isDebug: isDebug)
        : null;

    // Parse data
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
            configs: [map],
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
          configs: [map],
        );
      }
    }

    // Check for unexpected params
    if (isDebug && map.isNotEmpty) {
      throw ParseConfigException.unexpectedParams(
        params: map,
        parserType: UpdateRuleConfigParser,
        configs: [map],
      );
    }

    return UpdateRuleConfig<T>(
      when: when,
      rollout: rollout,
      data: data,
    );
  }
}
