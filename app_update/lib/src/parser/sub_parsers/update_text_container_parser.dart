// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment, prefer-correct-identifier-length, avoid-recursive-calls, avoid-non-null-assertion, avoid-explicit-type-declaration

part of '../update_config_parser.dart';

class UpdateTextContainerParser {
  UpdateTextParser get _updateTextParser => const UpdateTextParser();

  const UpdateTextContainerParser();

  UpdateTextConfigContainer? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
  }) {
    if (value is! Map?) {
      throw const UpdateConfigException();
    }

    if (value == null || value.isEmpty) return null;

    // ignore: avoid-unnecessary-type-assertions
    if (value is! Map<String, dynamic>) return null;

    final map = processInputMap<UpdateTextConfig>(
      value,
      parse: (e) => _updateTextParser.parse(e, isDebug: false),
    );

    return UpdateTextConfigContainer(map);
  }

  Map<UpdateAlertTypeBase, Map<VersionStatusBase, Map<Locale, D>>> processInputMap<D>(
    Map<String, dynamic> inputMap, {
    required D? Function(Map<String, dynamic> value) parse,
  }) {
    final result = <UpdateAlertTypeBase, Map<VersionStatusBase, Map<Locale, D>>>{};

    void traverse({
      required Map<String, dynamic> currentMap,
      UpdateAlertTypeBase? currentAlertType,
      VersionStatusBase? currentVersionStatus,
      Locale? currentLocale,
    }) {
      final isContainsBase = currentMap.containsKey('base');
      final isByType = currentMap.keys.any((e) => UpdateAlertTypeBase.parse(e, includeBase: false) != null);
      final isByStatus = currentMap.keys.any((e) => VersionStatusBase.parse(e, includeBase: false) != null);
      final isByLocale = currentMap.keys.every((e) => e.length == 2);

      if (!isByType && !isByStatus && !isByLocale && !isContainsBase) {
        final alertType = currentAlertType ?? UpdateAlertTypeBase.base;
        final versionStatus = currentVersionStatus ?? VersionStatusBase.base;
        final locale = currentLocale ?? const Locale('base');

        final parsedValue = parse(currentMap);

        if (parsedValue == null) return;

        final versionMap = result.putIfAbsent(alertType, () => {});
        final localeMap = versionMap.putIfAbsent(versionStatus, () => {});
        localeMap.putIfAbsent(locale, () => parsedValue);

        return;
      }

      currentMap.forEach((key, value) {
        if (value is! Map<String, dynamic>) return;

        var newAlertType = currentAlertType;
        var newVersionStatus = currentVersionStatus;
        var newLocale = currentLocale;

        if (isByType) {
          newAlertType = UpdateAlertTypeBase.parse(key);
          if (newAlertType == null) return;
        } else if (isByStatus) {
          newVersionStatus = VersionStatusBase.parse(key);
          if (newVersionStatus == null) return;
        } else if (isByLocale) {
          newLocale = Locale(key.toLowerCase());
        }

        traverse(
          currentMap: value,
          currentAlertType: newAlertType,
          currentVersionStatus: newVersionStatus,
          currentLocale: newLocale,
        );
      });
    }

    traverse(currentMap: inputMap);

    return result;
  }
}
