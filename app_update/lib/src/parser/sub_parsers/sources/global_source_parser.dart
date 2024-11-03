// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

part of '../../update_config_parser.dart';

class GlobalSourceParser {
  UpdateSettingsContainerParser get _updateSettingsContainerParser => const UpdateSettingsContainerParser();
  UpdateTextContainerParser get _updateTextContainerParser => const UpdateTextContainerParser();
  VersionSettingsParser get _versionSettingsParser => const VersionSettingsParser();
  GlobalPlatformParser get _platformParser => const GlobalPlatformParser();

  const GlobalSourceParser();

  GlobalSourceConfig? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
    required bool isOverride,
  }) {
    if (value is! Map<String, dynamic>) {
      if (isDebug) throw const UpdateConfigException();

      return null;
    }

    final map = value;

    // name
    final name = map.remove('name');
    if (name is! String?) throw const UpdateConfigException();

    if (!isOverride && name == null) throw const UpdateConfigException();

    // url
    final urlValue = map.remove('url');
    if (urlValue is! String?) {
      throw const UpdateConfigException();
    }

    if (!isOverride && urlValue == null) throw const UpdateConfigException();

    Uri? url;
    try {
      url = urlValue == null ? null : Uri.parse(urlValue);
    } catch (e, s) {
      if (isDebug) Error.throwWithStackTrace(const UpdateConfigException(), s);
    }

    // platforms
    final platformsValue = map.remove('platforms');
    if (platformsValue is! List?) throw const UpdateConfigException();

    final platforms = platformsValue
        ?.map((e) => _platformParser.parse(e, isDebug: isDebug))
        .whereType<GlobalPlatformConfig>()
        .toList();

    // updateSettings
    final updateSettingsValue = map.remove('settings');
    final updateSettings = _updateSettingsContainerParser.parse(
      updateSettingsValue,
      isDebug: isDebug,
    );

    // text
    final textValue = map.remove('text');
    final text = _updateTextContainerParser.parse(textValue, isDebug: isDebug);

    // versionSettings
    final versionSettingsValue = map.remove('version_settings');
    final versionSettings = _versionSettingsParser.parse(
      versionSettingsValue,
      isDebug: isDebug,
    );

    return GlobalSourceConfig(
      name: name,
      url: url,
      platforms: platforms,
      text: text,
      settings: updateSettings,
      versionSettings: versionSettings,
      customData: map,
    );
  }
}
