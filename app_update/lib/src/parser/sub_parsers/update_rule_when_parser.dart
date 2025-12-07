import '../../models/update_rule/update_rule_when.dart';
import '../base_parsers/app_status_parser.dart';
import '../base_parsers/custom_params_parser.dart';
import '../base_parsers/update_locale_parser.dart';
import '../base_parsers/update_platform_parser.dart';
import '../base_parsers/update_source_parser.dart';
import '../base_parsers/update_version_constraint_parser.dart';
import '../base_parsers/update_view_target_parser.dart';
import '../parse_config_exeption.dart';
import '../primitive_parsers/list_or_value_parser.dart';

class UpdateRuleWhenParser {
  static const _appStatusParser = AppStatusParser();
  static const _updateLocaleParser = UpdateLocaleParser();
  static const _updateViewTargetParser = UpdateViewTargetParser();
  static const _updateVersionConstraintParser = UpdateVersionConstraintParser();
  static const _updateSourceParser = UpdateSourceParser();
  static const _updatePlatformParser = UpdatePlatformParser();
  static const _listOrValueParser = ListOrValueParser();
  static const _customParamsParser = CustomParamsParser();

  const UpdateRuleWhenParser();

  UpdateRuleWhen? parse(
    Object? value, {
    required bool isDebug,
  }) {
    if (value == null) return null;

    if (value is! Map) {
      throw ParseConfigException.wrongType(
        rightType: Map,
        wrongType: value.runtimeType,
        parserType: UpdateRuleWhenParser,
        configs: [value],
      );
    }

    final map = Map<String, dynamic>.from(value);

    // appStatusIs
    final appStatusIsRawValue = map.remove('app_status_is');
    final appStatusIsValue = _listOrValueParser.parse(appStatusIsRawValue);
    final appStatusIs =
        appStatusIsValue?.map(_appStatusParser.parse).nonNulls.toList();

    // localeIs
    final localeIsRawValue = map.remove('locale_is');
    final localeIsValue = _listOrValueParser.parse(localeIsRawValue);
    final localeIs =
        localeIsValue?.map(_updateLocaleParser.parse).nonNulls.toList();

    // viewTargetIs
    final viewTargetIsRawValue = map.remove('view_target_is');
    final viewTargetIsValue = _listOrValueParser.parse(viewTargetIsRawValue);
    final viewTargetIs =
        viewTargetIsValue?.map(_updateViewTargetParser.parse).nonNulls.toList();

    // appVersionIs
    final appVersionIsRawValue = map.remove('app_version_is');
    final appVersionIsValue = _listOrValueParser.parse(appVersionIsRawValue);
    final appVersionIs = appVersionIsValue
        ?.map(_updateVersionConstraintParser.parse)
        .nonNulls
        .toList();

    // sourceIs
    final sourceIsRawValue = map.remove('source_is');
    final sourceIsValue = _listOrValueParser.parse(sourceIsRawValue);
    final sourceIs =
        sourceIsValue?.map(_updateSourceParser.parse).nonNulls.toList();

    // platformIs
    final platformIsRawValue = map.remove('platform_is');
    final platformIsValue = _listOrValueParser.parse(platformIsRawValue);
    final platformIs =
        platformIsValue?.map(_updatePlatformParser.parse).nonNulls.toList();

    // customParams
    final customParamsValue = map.remove('custom_params');
    final customParams = _customParamsParser.parse(customParamsValue);

    if (isDebug && map.isNotEmpty) {
      throw ParseConfigException.unexpectedParams(
        params: map,
        parserType: UpdateRuleWhenParser,
        configs: [value],
      );
    }

    return UpdateRuleWhen(
      appStatusIs: appStatusIs,
      localeIs: localeIs,
      viewTargetIs: viewTargetIs,
      appVersionIs: appVersionIs,
      sourceIs: sourceIs,
      platformIs: platformIs,
      customParams: customParams,
    );
  }
}
