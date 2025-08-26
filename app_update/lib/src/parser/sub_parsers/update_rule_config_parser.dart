// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../shared/models/mergeable.dart';
import '../../shared/models/update_rule/update_rule_config.dart';
import '../base_parsers/app_status_parser.dart';
import '../base_parsers/update_date_parser.dart';
import '../base_parsers/update_locale_parser.dart';
import '../base_parsers/update_source_parser.dart';
import '../base_parsers/update_version_constraint_parser.dart';
import '../base_parsers/update_view_target_parser.dart';
import '../common.dart';
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

  const UpdateRuleConfigParser();

  UpdateRuleConfig<T>? parse<T extends Mergeable>(
    dynamic value, {
    required T? Function(dynamic) dataParser,
  }) {
    if (value == null) return null;

    if (value is! Map) {
      throw const UpdateConfigException();
    }

    final map = Map<String, dynamic>.from(value);

    // data
    // if not exists, use rule itself as data
    final dataValue = map.remove('data') ?? value;
    final data = dataParser(dataValue);

    if (data == null) {
      return null;
    }

    // appStatuses
    final appStatusesRawValue = map.remove('app_status_is');
    final appStatusesValue = _listOrValueParser.parse(appStatusesRawValue);
    final appStatusIs =
        appStatusesValue?.map(_appStatusParser.parse).nonNulls.toList();

    // locales
    final localesRawValue = map.remove('locale_is');
    final localesValue = _listOrValueParser.parse(localesRawValue);
    final localeIs =
        localesValue?.map(_updateLocaleParser.parse).nonNulls.toList();

    // viewTargets
    final viewTargetsRawValue = map.remove('view_target_is');
    final viewTargetsValue = _listOrValueParser.parse(viewTargetsRawValue);
    final viewTargetIs =
        viewTargetsValue?.map(_updateViewTargetParser.parse).nonNulls.toList();

    // versions
    final versionsRawValue = map.remove('version_is');
    final versionsValue = _listOrValueParser.parse(versionsRawValue);
    final versionIs = versionsValue
        ?.map(_updateVersionConstraintParser.parse)
        .nonNulls
        .toList();

    // sources
    final sourcesRawValue = map.remove('source_is');
    final sourcesValue = _listOrValueParser.parse(sourcesRawValue);
    final sourceIs =
        sourcesValue?.map(_updateSourceParser.parse).nonNulls.toList();

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

    final config = UpdateRuleConfig<T>.byRequired(
      appStatusIs: appStatusIs,
      localeIs: localeIs,
      viewTargetIs: viewTargetIs,
      versionIs: versionIs,
      sourceIs: sourceIs,
      date: date,
      delay: delay,
      rollout: rollout,
      segmentationPercent: segmentationPercent,
      data: data,
      customData: map,
    );

    return config;
  }
}
