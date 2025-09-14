import '../../models/update_rule/update_rule_rollout.dart';
import '../base_parsers/custom_params_parser.dart';
import '../base_parsers/update_date_parser.dart';
import '../parse_config_exeption.dart';
import '../primitive_parsers/double_parser.dart';
import '../primitive_parsers/duration_parser.dart';

class UpdateRuleRolloutParser {
  static const _updateDateParser = UpdateDateParser();
  static const _durationParser = DurationParser();
  static const _doubleParser = DoubleParser();
  static const _customParamsParser = CustomParamsParser();

  const UpdateRuleRolloutParser();

  UpdateRuleRollout? parse(
    Object? value, {
    required bool isDebug,
  }) {
    if (value == null) return null;

    if (value is! Map) {
      throw ParseConfigException.wrongType(
        rightType: Map,
        wrongType: value.runtimeType,
        parserType: UpdateRuleRolloutParser,
        configs: [value],
      );
    }

    final map = Map<String, dynamic>.from(value);

    // date
    final dateValue = map.remove('date');
    final date = _updateDateParser.parse(dateValue);

    // delay_hours
    final delayHoursValue = map.remove('delay_hours');
    final delay = _durationParser.parse(hours: delayHoursValue);

    // rollout_hours
    final rolloutHoursValue = map.remove('rollout_hours');
    final rollout = _durationParser.parse(hours: rolloutHoursValue);

    // segmentation_percent
    final segmentationPercentValue = map.remove('segmentation_percent');
    final segmentationPercent =
        _doubleParser.parse(value: segmentationPercentValue);

    // customParams
    final customParamsValue = map.remove('custom_params');
    final customParams = _customParamsParser.parse(customParamsValue);

    if (isDebug && map.isNotEmpty) {
      throw ParseConfigException.unexpectedParams(
        params: map,
        parserType: UpdateRuleRolloutParser,
        configs: [value],
      );
    }

    return UpdateRuleRollout(
      date: date,
      delay: delay,
      rollout: rollout,
      segmentationPercent: segmentationPercent,
      customParams: customParams,
    );
  }
}
