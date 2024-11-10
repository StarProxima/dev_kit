// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment, avoid-recursive-calls

part of '../update_config_parser.dart';

class RawContainerParser {
  const RawContainerParser();

  Map<Locale, Map<UpdateAlertTypeBase, Map<VersionStatusBase, D>>> parse<D>(
    Map<String, dynamic> inputMap, {
    required D? Function(Map<String, dynamic> value) parse,
    // ignore: prefer-boolean-prefixes
    bool includeLocale = true,
  }) {
    final result = <Locale, Map<UpdateAlertTypeBase, Map<VersionStatusBase, D>>>{};

    // Рекурсивный обход, чтобы обработать любой порядок у
    // Locale, UpdateAlertTypeBase и VersionStatusBase, а также их отсутствие (считается за base).
    void traverse({
      required Map<String, dynamic> currentMap,
      UpdateAlertTypeBase? currentAlertType,
      VersionStatusBase? currentVersionStatus,
      Locale? currentLocale,
    }) {
      final isContainsBase = currentMap.containsKey('base');
      final isByType = currentMap.keys.any((e) => UpdateAlertTypeBase.parse(e, includeBase: false) != null);
      final isByStatus = currentMap.keys.any((e) => VersionStatusBase.parse(e, includeBase: false) != null);
      final isByLocale = includeLocale && !isByType && !isByStatus && currentMap.keys.every((e) => e.length == 2);

      if (!isByType && !isByStatus && !isByLocale && !isContainsBase) {
        final alertType = currentAlertType ?? UpdateAlertTypeBase.base;
        final versionStatus = currentVersionStatus ?? VersionStatusBase.base;
        final locale = currentLocale ?? const Locale('base');

        final parsedValue = parse(currentMap);

        if (parsedValue == null) return;

        final typeMap = result.putIfAbsent(locale, () => {});
        final versionMap = typeMap.putIfAbsent(alertType, () => {});
        versionMap.putIfAbsent(versionStatus, () => parsedValue);

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
