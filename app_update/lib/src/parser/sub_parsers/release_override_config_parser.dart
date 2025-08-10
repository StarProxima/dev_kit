// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../shared/models/release/release_override_config.dart';
import '../common.dart';
import '../primitive_parsers/date_time_parser.dart';
import '../primitive_parsers/version_parser.dart';

class ReleaseOverrideConfigParser {
  static const _versionParser = VersionParser();
  static const _dateTimeParser = DateTimeParser();

  const ReleaseOverrideConfigParser();

  ReleaseOverrideConfig? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! Map) {
      throw const UpdateConfigException();
    }

    final map = Map<String, dynamic>.from(value);

    // version
    final versionValue = map.remove('version');
    final version = _versionParser.parse(versionValue);

    // date
    final dateValue = map.remove('date');
    final date = _dateTimeParser.parse(dateValue);

    return ReleaseOverrideConfig.byRequired(
      version: version,
      date: date,
      customData: map,
    );
  }
}
