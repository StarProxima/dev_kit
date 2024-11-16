import 'dart:ui';

import '../../shared/update_alert_type.dart';
import '../../shared/version_status.dart';
import 'update_text_data.dart';

class UpdateTextDataContainer {
  final Map<Locale, Map<UpdateAlertTypeBase, Map<VersionStatusBase, UpdateTextData>>> value;

  const UpdateTextDataContainer(this.value);

  UpdateTextDataContainer inherit(UpdateTextDataContainer child) {
    final inheritedValue = {...child.value};

    for (final byLocale in value.entries) {
      final childByLocale = inheritedValue[byLocale.key];

      if (childByLocale == null) {
        inheritedValue[byLocale.key] = byLocale.value;
        continue;
      }

      for (final byType in byLocale.value.entries) {
        final childByType = childByLocale[byType.key];
        if (childByType == null) {
          childByLocale[byType.key] = byType.value;
          continue;
        }

        for (final byStatus in byType.value.entries) {
          final childByStatus = childByType[byStatus.key];
          if (childByStatus == null) {
            childByType[byStatus.key] = byStatus.value;
            continue;
          }

          final childText = childByStatus;
          childByType[byStatus.key] = byStatus.value.inherit(childText);
        }
      }
    }

    return UpdateTextDataContainer(inheritedValue);
  }

  UpdateTextData? getBy({
    required Locale locale,
    required UpdateAlertType type,
    required VersionStatus status,
  }) =>
      getByBase(
        locale: locale,
        type: type.toBase(),
        status: status.toBase(),
      );

  UpdateTextData? getByBase({
    required Locale locale,
    required UpdateAlertTypeBase type,
    required VersionStatusBase status,
  }) {
    final combinations = [
      (const Locale('base'), UpdateAlertTypeBase.base, VersionStatusBase.base),
      (const Locale('base'), UpdateAlertTypeBase.base, status),
      (const Locale('base'), type, VersionStatusBase.base),
      (const Locale('base'), type, status),
      (locale, UpdateAlertTypeBase.base, VersionStatusBase.base),
      (locale, UpdateAlertTypeBase.base, status),
      (locale, type, VersionStatusBase.base),
      (locale, type, status),
    ];

    UpdateTextData? textData;

    for (final combination in combinations) {
      // ignore: avoid-positional-record-field-access
      final byCombination = value[combination.$1]?[combination.$2]?[combination.$3];
      textData = textData?.inherit(byCombination) ?? byCombination ?? textData;
    }

    return textData;
  }
}
