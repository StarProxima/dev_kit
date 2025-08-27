import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  group('UpdateContentInterpolator', () {
    const interpolator = UpdateContentInterpolator();

    group('buildInterpolateData', () {
      test('создает правильную мапу данных для интерполяции', () {
        final searchData = UpdateSearchData(
          currentDate: DateTime(2024, 10, 15),
          localVersion: Version.parse('1.2.3+45'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appName: 'Test App',
          appPackageName: 'com.test.app',
          appStatus: AppStatus.active,
          locale: UpdateLocale.any,
          displayTarget: UpdateViewTarget.any,
          rolloutPointer: 0.5,
          segmentationPointer: 0.3,
          localReleaseDate: DateTime(2024, 10),
          updateReleaseDate: DateTime(2024, 10, 10),
          customData: null,
        );

        final updateData = UpdateData(
          version: Version.parse('2.0.0+67'),
          date: DateTime(2024, 10, 10),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
          contentRules: [],
          settingsRules: [],
          appSettingsRules: [],
          customData: null,
        );

        final result = interpolator.buildInterpolateData(
          searchData: searchData,
          updateData: updateData,
        );

        expect(result['appVersion'], '1.2.3');
        expect(result['appVersionWithBuild'], '1.2.3+45');
        expect(result['localVersion'], '1.2.3');
        expect(result['localVersionWithBuild'], '1.2.3+45');
        expect(result['updateVersion'], '2.0.0');
        expect(result['updateVersionWithBuild'], '2.0.0+67');
        expect(result['appName'], 'Test App');
        expect(result['appPackageName'], 'com.test.app');
        expect(result['sourceName'], 'GooglePlay');
      });

      test('обрабатывает кастомные названия источников', () {
        final searchData = UpdateSearchData(
          currentDate: DateTime(2024, 10, 15),
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [
            UpdateSource.custom(UpdateSourceName.custom('my custom store'))
          ],
          appName: 'App',
          appPackageName: 'com.app',
          appStatus: AppStatus.active,
          locale: UpdateLocale.any,
          displayTarget: UpdateViewTarget.any,
          rolloutPointer: 0.5,
          segmentationPointer: 0.3,
          localReleaseDate: null,
          updateReleaseDate: null,
          customData: null,
        );

        final updateData = UpdateData(
          version: Version.parse('1.1.0'),
          date: DateTime(2024, 10, 10),
          sourceName: const UpdateSourceName.custom('my custom store'),
          platform: UpdatePlatform.android,
          contentRules: [],
          settingsRules: [],
          appSettingsRules: [],
          customData: null,
        );

        final result = interpolator.buildInterpolateData(
          searchData: searchData,
          updateData: updateData,
        );

        expect(result['sourceName'], 'My Custom Store');
      });

      test('обрабатывает версии без build number', () {
        final searchData = UpdateSearchData(
          currentDate: DateTime(2024, 10, 15),
          localVersion: Version.parse('1.2.3'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appName: 'App',
          appPackageName: 'com.app',
          appStatus: AppStatus.active,
          locale: UpdateLocale.any,
          displayTarget: UpdateViewTarget.any,
          rolloutPointer: 0.5,
          segmentationPointer: 0.3,
          localReleaseDate: null,
          updateReleaseDate: null,
          customData: null,
        );

        final updateData = UpdateData(
          version: Version.parse('2.0.0'),
          date: DateTime(2024, 10, 10),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
          contentRules: [],
          settingsRules: [],
          appSettingsRules: [],
          customData: null,
        );

        final result = interpolator.buildInterpolateData(
          searchData: searchData,
          updateData: updateData,
        );

        expect(result['appVersionWithBuild'], '1.2.3');
        expect(result['updateVersionWithBuild'], '2.0.0');
      });
    });

    group('interpolate', () {
      test('интерполирует содержимое с правильными переменными', () {
        final updateContentTemplate = UpdateContentData(
          updateUrl: Uri.parse('https://placeholder.com'),
          title: 'Update {appName} to {updateVersion}',
          description:
              'Your current version {localVersion} is outdated. Update from {sourceName}!',
          releaseNotesTitle: 'Release Notes',
          releaseNotes:
              'Version {updateVersionWithBuild} includes new features.',
          skipButton: 'Skip',
          postponeButton: 'Later',
          updateButton: 'Update {appName}',
          customData: {
            'custom_field': 'App: {appName}, Version: {updateVersion}'
          },
        );

        final searchData = UpdateSearchData(
          currentDate: DateTime(2024, 10, 15),
          localVersion: Version.parse('1.0.0+10'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appName: 'My App',
          appPackageName: 'com.myapp',
          appStatus: AppStatus.active,
          locale: UpdateLocale.any,
          displayTarget: UpdateViewTarget.any,
          rolloutPointer: 0.5,
          segmentationPointer: 0.3,
          localReleaseDate: null,
          updateReleaseDate: null,
          customData: null,
        );

        final updateData = UpdateData(
          version: Version.parse('2.1.5+25'),
          date: DateTime(2024, 10, 10),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
          contentRules: [],
          settingsRules: [],
          appSettingsRules: [],
          customData: null,
        );

        final result = interpolator.interpolate(
          updateContent: updateContentTemplate,
          searchData: searchData,
          updateData: updateData,
        );

        expect(result.title, 'Update My App to 2.1.5');
        expect(result.description,
            'Your current version 1.0.0 is outdated. Update from GooglePlay!');
        expect(result.releaseNotes, 'Version 2.1.5+25 includes new features.');
        expect(result.updateButton, 'Update My App');
        expect(result.updateUrl.toString(),
            'https://placeholder.com'); // Uri не интерполируется
        expect(
            result.customData!['custom_field'], 'App: My App, Version: 2.1.5');
      });

      test('не изменяет содержимое без переменных', () {
        final updateContent = UpdateContentData(
          updateUrl: Uri.parse('https://example.com'),
          title: 'Simple Title',
          description: 'Simple description without variables',
          releaseNotesTitle: "What's New",
          releaseNotes: 'No variables here',
          skipButton: 'Skip',
          postponeButton: 'Later',
          updateButton: 'Update Now',
          customData: {'field': 'value'},
        );

        final searchData = UpdateSearchData(
          currentDate: DateTime(2024, 10, 15),
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appName: 'App',
          appPackageName: 'com.app',
          appStatus: AppStatus.active,
          locale: UpdateLocale.any,
          displayTarget: UpdateViewTarget.any,
          rolloutPointer: 0.5,
          segmentationPointer: 0.3,
          localReleaseDate: null,
          updateReleaseDate: null,
          customData: null,
        );

        final updateData = UpdateData(
          version: Version.parse('2.0.0'),
          date: DateTime(2024, 10, 10),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
          contentRules: [],
          settingsRules: [],
          appSettingsRules: [],
          customData: null,
        );

        final result = interpolator.interpolate(
          updateContent: updateContent,
          searchData: searchData,
          updateData: updateData,
        );

        expect(result.title, 'Simple Title');
        expect(result.description, 'Simple description without variables');
        expect(result.releaseNotes, 'No variables here');
        expect(result.updateButton, 'Update Now');
        expect(result.updateUrl.toString(), 'https://example.com');
        expect(result.customData!['field'], 'value');
      });

      test('обрабатывает частичную интерполяцию', () {
        final updateContent = UpdateContentData(
          updateUrl: Uri.parse('https://example.com'),
          title: '{appName} version {localVersion} → {updateVersion}',
          description: 'Some text {unknownVariable} and {appName}',
          releaseNotesTitle: 'Release Notes',
          releaseNotes: null,
          skipButton: 'Skip',
          postponeButton: 'Later',
          updateButton: 'Update',
          customData: null,
        );

        final searchData = UpdateSearchData(
          currentDate: DateTime(2024, 10, 15),
          localVersion: Version.parse('1.5.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appName: 'Test App',
          appPackageName: 'com.test',
          appStatus: AppStatus.active,
          locale: UpdateLocale.any,
          displayTarget: UpdateViewTarget.any,
          rolloutPointer: 0.5,
          segmentationPointer: 0.3,
          localReleaseDate: null,
          updateReleaseDate: null,
          customData: null,
        );

        final updateData = UpdateData(
          version: Version.parse('2.0.0'),
          date: DateTime(2024, 10, 10),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
          contentRules: [],
          settingsRules: [],
          appSettingsRules: [],
          customData: null,
        );

        final result = interpolator.interpolate(
          updateContent: updateContent,
          searchData: searchData,
          updateData: updateData,
        );

        expect(result.title, 'Test App version 1.5.0 → 2.0.0');
        expect(result.description, 'Some text {unknownVariable} and Test App');
        expect(result.releaseNotes, isNull);
        expect(result.updateButton, 'Update');
        expect(result.updateUrl.toString(), 'https://example.com');
        expect(result.customData, isNull);
      });

      test('работает с пустыми и null полями', () {
        final updateContent = UpdateContentData(
          updateUrl: Uri.parse('https://example.com'),
          title: 'Default Title',
          description: '',
          releaseNotesTitle: 'Updates',
          releaseNotes: '{updateVersion}',
          skipButton: 'Skip',
          postponeButton: 'Later',
          updateButton: 'Update',
          customData: null,
        );

        final searchData = UpdateSearchData(
          currentDate: DateTime(2024, 10, 15),
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appName: 'App',
          appPackageName: 'com.app',
          appStatus: AppStatus.active,
          locale: UpdateLocale.any,
          displayTarget: UpdateViewTarget.any,
          rolloutPointer: 0.5,
          segmentationPointer: 0.3,
          localReleaseDate: null,
          updateReleaseDate: null,
          customData: null,
        );

        final updateData = UpdateData(
          version: Version.parse('2.0.0'),
          date: DateTime(2024, 10, 10),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
          contentRules: [],
          settingsRules: [],
          appSettingsRules: [],
          customData: null,
        );

        final result = interpolator.interpolate(
          updateContent: updateContent,
          searchData: searchData,
          updateData: updateData,
        );

        expect(result.title, 'Default Title');
        expect(result.description, '');
        expect(result.releaseNotes, '2.0.0');
        expect(result.updateButton, 'Update');
        expect(result.updateUrl.toString(), 'https://example.com');
        expect(result.customData, isNull);
      });
    });
  });
}
