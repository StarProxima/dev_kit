// ignore_for_file: avoid-accessing-other-classes-private-members, avoid-unnecessary-getter, avoid-collection-mutating-methods, avoid-missing-enum-constant-in-map, avoid-non-null-assertion
import 'dart:ui';

import '../../linker/models/update_container_storage.dart';
import '../../linker/models/update_text_data.dart';
import '../../linker/models/update_text_data_container.dart';
import '../../shared/update_alert_type.dart';
import '../../shared/version_status.dart';
import 'update_texts.dart';

class UpdateTextContainer {
  final UpdateTextDataContainer defaultContainer;
  final UpdateTextDataContainer? controllerContainer;
  final UpdateContainerStorage<UpdateTextDataContainer> containerStorage;

  // ignore: prefer-correct-callback-field-name
  final UpdateText Function(UpdateText text) interpolate;

  const UpdateTextContainer({
    required this.defaultContainer,
    required this.controllerContainer,
    required this.containerStorage,
    required this.interpolate,
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
    // Store in a map to make it more clear which specific containers are merged next
    final dataFromAllContainers = {
      'default': defaultContainer.getByBase(locale: locale, type: type, status: status),
      'controller': controllerContainer?.getByBase(locale: locale, type: type, status: status),
      'global': containerStorage.global?.getByBase(locale: locale, type: type, status: status),
      'globalSource': containerStorage.globalSource?.getByBase(locale: locale, type: type, status: status),
      'globalSourcePlatform':
          containerStorage.globalSourcePlatform?.getByBase(locale: locale, type: type, status: status),
      'release': containerStorage.release?.getByBase(locale: locale, type: type, status: status),
      'releaseSource': containerStorage.releaseSource?.getByBase(locale: locale, type: type, status: status),
      'releaseSourcePlatform':
          containerStorage.releaseSourcePlatform?.getByBase(locale: locale, type: type, status: status),
    };

    UpdateTextData? textData;

    // ignore: unused_local_variable
    for (final MapEntry(key: name, :value) in dataFromAllContainers.entries) {
      if (value == null) continue;
      textData = textData?.merge(value) ?? value;
    }

    if (textData == null) throw Exception('UpdateTextData has null field');

    try {
      final updateText = UpdateText(
        title: textData.title!,
        description: textData.description!,
        releaseNotesTitle: textData.releaseNotesTitle!,
        releaseNotes: textData.releaseNotes!,
        skipButton: textData.skipButton!,
        laterButton: textData.laterButton!,
        updateButton: textData.updateButton!,
        customData: textData.customData,
      );

      final interpolatedUpdateText = interpolate(updateText);

      return interpolatedUpdateText;
    } catch (e, s) {
      Error.throwWithStackTrace(Exception('UpdateTextData has null field'), s);
    }
  }
}
