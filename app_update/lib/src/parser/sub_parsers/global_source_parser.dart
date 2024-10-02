// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

part of '../update_config_parser.dart';

class GlobalSourceParser {
  UpdateSettingsParser get _updateSettingsParser => const UpdateSettingsParser();

  const GlobalSourceParser();

  GlobalSourceConfig? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
  }) {
    if (value is! Map<String, dynamic>) {
      if (isDebug) throw const UpdateConfigException();

      return null;
    }

    // full syntax

    final map = value;

    // name
    final name = map.remove('name');
    if (name is! String) throw const UpdateConfigException();

    // url
    final urlValue = map.remove('url');
    if (urlValue is! String) throw const UpdateConfigException();

    final url = Uri.tryParse(urlValue);
    if (url == null) throw const UpdateConfigException();

    // platforms
    final platformsValue = map.remove('platforms');
    if (platformsValue is! List<String>) throw const UpdateConfigException();
    final platforms = platformsValue.map(UpdatePlatform.new).toList();

    //  releaseSettings
    final settingsValue = map.remove('settings');
    final settings = _updateSettingsParser.parse(
      settingsValue,
      isDebug: isDebug,
    );

    return GlobalSourceConfig(
      name: name,
      url: url,
      platforms: platforms,
      settings: settings,
      customData: map,
    );
  }
}
