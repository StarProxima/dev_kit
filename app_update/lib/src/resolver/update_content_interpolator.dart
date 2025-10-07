import 'package:flutter/material.dart';

import '../models/release/update_data.dart';
import '../models/update_content/update_content_data.dart';
import '../models/update_search/update_search_data.dart';
import '../utils/version_x.dart';

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
  @visibleForTesting
  Map<String, String> buildInterpolateData({
    required UpdateSearchData searchData,
    required UpdateData updateData,
  }) {
    final appVersionStr = searchData.appVersion.toOnlyNumbersString();
    final appVersionWithBuildStr =
        searchData.appVersion.toVersionWithBuildString();
    final updateVersionStr = updateData.version.toOnlyNumbersString();
    final updateVersionWithBuildStr =
        updateData.version.toVersionWithBuildString();

    final interpolateData = {
      'appVersion': appVersionStr,
      'appVersionWithBuild': appVersionWithBuildStr,
      'localVersion': appVersionStr,
      'localVersionWithBuild': appVersionWithBuildStr,
      'updateVersion': updateVersionStr,
      'releaseVersion': updateVersionStr,
      'updateVersionWithBuild': updateVersionWithBuildStr,
      'releaseVersionWithBuild': updateVersionWithBuildStr,
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
