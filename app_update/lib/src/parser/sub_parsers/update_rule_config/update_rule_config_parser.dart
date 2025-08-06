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
import '../../update_config_exception.dart';
import 'update_rule_config.dart';

class UpdateRuleConfigParser {
  static const _appStatusParser = AppStatusParser();
  static const _updateLocaleParser = UpdateLocaleParser();
  static const _updateViewTargetParser = UpdateViewTargetParser();
  static const _updateVersionConstraintParser = UpdateVersionConstraintParser();
  static const _updateSourceParser = UpdateSourceParser();
  static const _updateDateParser = UpdateDateParser();
  static const _listOrValueParser = ListOrValueParser();

  const UpdateRuleConfigParser();

  UpdateRuleConfig<T>? parse<T>(
    dynamic value, {
    required T Function(dynamic) dataParser,
  }) {
    if (value is! Map<String, dynamic>?) {
      throw const UpdateConfigException();
    }

    if (value == null) return null;

    // appStatuses
    final appStatusesRawValue = value.remove('app_statuses');
    final appStatusesValue = _listOrValueParser.parse(appStatusesRawValue);
    final appStatuses = appStatusesValue?.map(_appStatusParser.parse).whereType<AppStatus>().toList();

    // locales
    final localesRawValue = value.remove('locales');
    final localesValue = _listOrValueParser.parse(localesRawValue);
    final locales = localesValue?.map(_updateLocaleParser.parse).whereType<UpdateLocale>().toList();

    // viewTargets
    final viewTargetsRawValue = value.remove('view_targets');
    final viewTargetsValue = _listOrValueParser.parse(viewTargetsRawValue);
    final viewTargets = viewTargetsValue?.map(_updateViewTargetParser.parse).whereType<UpdateViewTarget>().toList();

    // versions
    final versionsRawValue = value.remove('versions');
    final versionsValue = _listOrValueParser.parse(versionsRawValue);
    final versions =
        versionsValue?.map(_updateVersionConstraintParser.parse).whereType<UpdateVersionConstraint>().toList();

    // sources
    final sourcesRawValue = value.remove('sources');
    final sourcesValue = _listOrValueParser.parse(sourcesRawValue);
    final sources = sourcesValue?.map(_updateSourceParser.parse).whereType<UpdateSource>().toList();

    // date
    final dateValue = value.remove('date');
    final date = _updateDateParser.parse(dateValue);

    // data
    final dataValue = value.remove('data');
    final data = dataParser(dataValue);

    final config = UpdateRuleConfig.byRequired(
      appStatuses: appStatuses ?? [AppStatus.any],
      locales: locales ?? [UpdateLocale.any],
      viewTargets: viewTargets ?? [UpdateViewTarget.any],
      versions: versions ?? [UpdateVersionConstraint.any],
      sources: sources ?? [UpdateSource.any],
      date: date ?? UpdateDate.any,
      data: data,
      customData: value,
    );

    return config;
  }
}
