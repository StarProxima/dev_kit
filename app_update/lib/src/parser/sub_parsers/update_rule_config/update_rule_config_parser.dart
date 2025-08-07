// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../../shared/app_status.dart';
import '../../../shared/update_date.dart';
import '../../../shared/update_locale.dart';
import '../../../shared/update_source.dart';
import '../../../shared/update_version_constraint.dart';
import '../../../shared/update_view_target.dart';
import '../../base_parsers/app_status_parser.dart';
import '../../base_parsers/update_date_parser.dart';
import '../../base_parsers/update_locale_parser.dart';
import '../../base_parsers/update_source_parser.dart';
import '../../base_parsers/update_version_constraint_parser.dart';
import '../../base_parsers/update_view_target_parser.dart';
import '../../primitive_parsers/list_or_value_parser.dart';
import '../../primitive_parsers/duration_parser.dart';
import '../../primitive_parsers/double_parser.dart';
import '../../common.dart';
import 'update_rule_config.dart';

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

  UpdateRuleConfig<T>? parse<T>(
    dynamic value, {
    required T Function(dynamic) dataParser,
  }) {
    if (value == null) return null;

    if (value is! Map) {
      throw const UpdateConfigException();
    }

    final map = Map<String, dynamic>.from(value);

    // appStatuses
    final appStatusesRawValue = map.remove('app_statuses');
    final appStatusesValue = _listOrValueParser.parse(appStatusesRawValue);
    final appStatuses = appStatusesValue?.map(_appStatusParser.parse).nonNulls.toList();

    // locales
    final localesRawValue = map.remove('locales');
    final localesValue = _listOrValueParser.parse(localesRawValue);
    final locales = localesValue?.map(_updateLocaleParser.parse).nonNulls.toList();

    // viewTargets
    final viewTargetsRawValue = map.remove('view_targets');
    final viewTargetsValue = _listOrValueParser.parse(viewTargetsRawValue);
    final viewTargets = viewTargetsValue?.map(_updateViewTargetParser.parse).nonNulls.toList();

    // versions
    final versionsRawValue = map.remove('versions');
    final versionsValue = _listOrValueParser.parse(versionsRawValue);
    final versions = versionsValue?.map(_updateVersionConstraintParser.parse).nonNulls.toList();

    // sources
    final sourcesRawValue = map.remove('sources');
    final sourcesValue = _listOrValueParser.parse(sourcesRawValue);
    final sources = sourcesValue?.map(_updateSourceParser.parse).nonNulls.toList();

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
    final segmentationPercent = _doubleParser.parse(value: segmentationPercentValue);

    // data
    // if not exists, use rule itself as data
    final dataValue = map.remove('data') ?? value;
    final data = dataParser(dataValue);

    final config = UpdateRuleConfig<T>.byRequired(
      appStatuses: appStatuses ?? [AppStatus.any],
      locales: locales ?? [UpdateLocale.any],
      viewTargets: viewTargets ?? [UpdateViewTarget.any],
      versions: versions ?? [UpdateVersionConstraint.any],
      sources: sources ?? [UpdateSource.any],
      date: date ?? UpdateDate.any,
      delay: delay,
      rollout: rollout,
      segmentationPercent: segmentationPercent,
      data: data,
      customData: map,
    );

    return config;
  }
}
