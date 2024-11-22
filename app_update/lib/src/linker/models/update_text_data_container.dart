// ignore_for_file: avoid-missing-enum-constant-in-map

import 'dart:ui';

import '../../parser/models/update_text_config_container.dart';
import '../../shared/update_alert_type.dart';
import '../../shared/version_status.dart';
import 'update_text_data.dart';

class UpdateTextDataContainer {
  final Map<Locale, Map<UpdateAlertTypeBase, Map<VersionStatusBase, UpdateTextData>>> value;

  const UpdateTextDataContainer(this.value);

  static UpdateTextDataContainer? fromConfig(UpdateTextConfigContainer? config) {
    if (config == null) return null;

    return UpdateTextDataContainer(
      config.value.map(
        (key, value) => MapEntry(
          key,
          value.map(
            (key, value) => MapEntry(
              key,
              value.map(
                (key, value) => MapEntry(
                  key,
                  UpdateTextData.fromConfig(value),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
      textData = textData?.merge(byCombination) ?? byCombination ?? textData;
    }

    return textData;
  }
}
