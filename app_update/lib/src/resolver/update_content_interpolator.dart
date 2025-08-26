import 'package:flutter/material.dart';

import '../shared/models/release/update_data.dart';
import '../shared/models/update_content/update_content_data.dart';
import '../shared/models/update_search/update_search_data.dart';
import '../shared/utils/version_x.dart';

class UpdateContentInterpolator {
  const UpdateContentInterpolator();

  UpdateContentData interpolate({
    required UpdateContentData updateContent,
    required UpdateSearchData searchData,
    required UpdateData updateData,
  }) {
    final interpolateData = buildInterpolateData(
      searchData: searchData,
      updateData: updateData,
    );

    return updateContent.interpolate(interpolateData);
  }

  @protected
  Map<String, String> buildInterpolateData({
    required UpdateSearchData searchData,
    required UpdateData updateData,
  }) {
    final localVersionStr = searchData.localVersion.toOnlyNumbersString();
    final localVersionWithBuildStr =
        searchData.localVersion.toVersionWithBuildString();
    final updateVersionStr = updateData.version.toOnlyNumbersString();
    final updateVersionWithBuildStr =
        updateData.version.toVersionWithBuildString();

    final interpolateData = {
      'appVersion': localVersionStr,
      'appVersionWithBuild': localVersionWithBuildStr,
      'localVersion': localVersionStr,
      'localVersionWithBuild': localVersionWithBuildStr,
      'updateVersion': updateVersionStr,
      'updateVersionWithBuild': updateVersionWithBuildStr,
      'appName': searchData.appName,
      'appPackageName': searchData.appPackageName,
      'sourceName': capitalize(updateData.sourceName.originalName),
    };

    return interpolateData;
  }

  @protected
  String capitalize(String text) => text
      .split(' ')
      .map((e) => e.substring(0, 1).toUpperCase() + e.substring(1))
      .join(' ');
}
