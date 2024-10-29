// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

part of '../update_config_parser.dart';

class GlobalSourceParser {
  UpdateSettingsContainerParser get _updateSettingsParser => const UpdateSettingsContainerParser();
  VersionSettingsParser get _versionSettingsParser => const VersionSettingsParser();

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

    // updateSettings
    final updateSettingsValue = map.remove('settings');
    final updateSettings = _updateSettingsParser.parse(
      updateSettingsValue,
      isDebug: isDebug,
    );

    // updateSettings
    final versionSettingsValue = map.remove('version_settings');
    final versionSettings = _versionSettingsParser.parse(
      versionSettingsValue,
      isDebug: isDebug,
    );

    return GlobalSourceConfig(
      name: name,
      url: url,
      platforms: platforms,
      settings: updateSettings,
      versionSettings: versionSettings,
      customData: map,
    );
  }
}
