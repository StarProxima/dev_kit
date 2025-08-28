// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../models/update_rule/update_rule_config.dart';
import '../../utils/mergeable.dart';
import '../base_parsers/app_status_parser.dart';
import '../base_parsers/custom_params_parser.dart';
import '../base_parsers/update_date_parser.dart';
import '../base_parsers/update_locale_parser.dart';
import '../base_parsers/update_source_parser.dart';
import '../base_parsers/update_version_constraint_parser.dart';
import '../base_parsers/update_view_target_parser.dart';
import '../parse_config_exeption.dart';
import '../primitive_parsers/double_parser.dart';
import '../primitive_parsers/duration_parser.dart';
import '../primitive_parsers/list_or_value_parser.dart';

class UpdateRuleConfigParser {
  static const _appStatusParser = AppStatusParser();
  static const _updateLocaleParser = UpdateLocaleParser();
  static const _updateViewTargetParser = UpdateViewTargetParser();
  static const _updateVersionConstraintParser = UpdateVersionConstraintParser();
  static const _updateSourceParser = UpdateSourceParser();
  static const _updateDateParser = UpdateDateParser();
  static const _listOrValueParser = ListOrValueParser();
  static const _durationParser = DurationParser();
  static const _doubleParser = DoubleParser();
  static const _customParamsParser = CustomParamsParser();

  const UpdateRuleConfigParser();

  UpdateRuleConfig<T>? parse<T extends Mergeable<T>>(
    Object? value, {
    required T? Function(Object? value) dataParser,
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

    // customParams
    final customParamsValue = map.remove('custom_params');
    final customParams = _customParamsParser.parse(customParamsValue);

    // data
    // if not exists, use rule itself as data
    final dataValue = map.remove('data') ?? value;
    final data = dataParser(dataValue);

    if (data == null) {
      return null;
    }

    // appStatusIs
    final appStatusIsRawValue = map.remove('app_status_is');
    final appStatusIsValue = _listOrValueParser.parse(appStatusIsRawValue);
    final appStatusIs =
        appStatusIsValue?.map(_appStatusParser.parse).nonNulls.toList();

    // locales
    final localeIsRawValue = map.remove('locale_is');
    final localeIsValue = _listOrValueParser.parse(localeIsRawValue);
    final localeIs =
        localeIsValue?.map(_updateLocaleParser.parse).nonNulls.toList();

    // viewTargets
    final viewTargetIsRawValue = map.remove('view_target_is');
    final viewTargetIsValue = _listOrValueParser.parse(viewTargetIsRawValue);
    final viewTargetIs =
        viewTargetIsValue?.map(_updateViewTargetParser.parse).nonNulls.toList();

    // versions
    final appVersionIsRawValue = map.remove('app_version_is');
    final appVersionIsValue = _listOrValueParser.parse(appVersionIsRawValue);
    final appVersionIs = appVersionIsValue
        ?.map(_updateVersionConstraintParser.parse)
        .nonNulls
        .toList();

    // sources
    final sourceIsRawValue = map.remove('source_is');
    final sourceIsValue = _listOrValueParser.parse(sourceIsRawValue);
    final sourceIs =
        sourceIsValue?.map(_updateSourceParser.parse).nonNulls.toList();

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

    // Проверяем, что не осталось неизвестных параметров
    if (map.isNotEmpty) {
      throw ParseConfigException.unexpectedParams(
        params: map,
        parserType: UpdateRuleConfigParser,
        configs: [value],
      );
    }

    final config = UpdateRuleConfig<T>.byRequired(
      appStatusIs: appStatusIs,
      localeIs: localeIs,
      viewTargetIs: viewTargetIs,
      appVersionIs: appVersionIs,
      sourceIs: sourceIs,
      date: date,
      delay: delay,
      rollout: rollout,
      segmentationPercent: segmentationPercent,
      data: data,
      customParams: customParams,
    );

    return config;
  }
}
