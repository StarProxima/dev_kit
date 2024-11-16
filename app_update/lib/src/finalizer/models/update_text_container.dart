// ignore_for_file: avoid-accessing-other-classes-private-members, avoid-unnecessary-getter, avoid-collection-mutating-methods, avoid-missing-enum-constant-in-map, avoid-non-null-assertion
import 'dart:ui';

import '../../linker/models/update_text_data_container.dart';
import '../../shared/update_alert_type.dart';
import '../../shared/version_status.dart';
import 'update_texts.dart';

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
