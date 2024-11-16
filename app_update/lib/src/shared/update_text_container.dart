// ignore_for_file: avoid-accessing-other-classes-private-members, avoid-unnecessary-getter, avoid-collection-mutating-methods, avoid-missing-enum-constant-in-map, avoid-non-null-assertion
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../finalizer/models/update_texts.dart';
import '../linker/models/update_text_data.dart';
import '../parser/models/update_text_config.dart';
import 'update_alert_type.dart';
import 'version_status.dart';

class UpdateTextConfigContainer {
  final Map<Locale, Map<UpdateAlertTypeBase, Map<VersionStatusBase, UpdateTextConfig>>> value;

  const UpdateTextConfigContainer(this.value);

  UpdateTextConfigContainer.fromUpdateTextConfig(UpdateTextConfig config)
      : value = {
          const Locale('base'): {
            UpdateAlertTypeBase.base: {VersionStatusBase.base: config},
          },
        };

  @visibleForTesting
  UpdateTextConfig? getBy({
    required UpdateAlertType type,
    required VersionStatus status,
    required Locale locale,
  }) =>
      getByBase(
        type: type.toBase(),
        status: status.toBase(),
        locale: locale,
      );

  @visibleForTesting
  UpdateTextConfig? getByBase({
    required UpdateAlertTypeBase type,
    required VersionStatusBase status,
    required Locale locale,
  }) {
    final byLocale = value[locale] ?? value[const Locale('base')];
    final byType = byLocale?[type] ?? byLocale?[UpdateAlertTypeBase.base];
    final byStatus = byType?[status] ?? byType?[VersionStatusBase.base];

    return byStatus;
  }
}

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

class UpdateTextContainer {
  final UpdateTextDataContainer dataContainer;

  const UpdateTextContainer({
    required this.dataContainer,
  });

  UpdateText getBy({
    required Locale locale,
    required UpdateAlertType type,
    required VersionStatus status,
  }) =>
      getByBase(
        locale: locale,
        type: type.toBase(),
        status: status.toBase(),
      );

  UpdateText getByBase({
    required Locale locale,
    required UpdateAlertTypeBase type,
    required VersionStatusBase status,
  }) {
    final textData = dataContainer.getByBase(locale: locale, type: type, status: status);

    if (textData == null) throw Exception('UpdateTextData has null field');

    try {
      return UpdateText(
        title: textData.title!,
        description: textData.description!,
        releaseNotesTitle: textData.releaseNotesTitle!,
        releaseNotes: textData.releaseNotes!,
        skipButton: textData.skipButton!,
        laterButton: textData.laterButton!,
        updateButton: textData.updateButton!,
        customData: textData.customData,
      );
    } catch (e, s) {
      Error.throwWithStackTrace(Exception('UpdateTextData has null field'), s);
    }
  }
}
