// ignore_for_file: avoid-type-casts, no-empty-string

import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_semver/pub_semver.dart';

// Mock classes
class _MockUpdateRuleResolver extends Mock implements UpdateRuleResolver {}

class _MockUpdateContentInterpolator extends Mock
    implements UpdateContentInterpolator {}

void main() {
  group('UpdateResolver', () {
    late _MockUpdateRuleResolver mockRuleResolver;
    late _MockUpdateContentInterpolator mockContentInterpolator;
    late UpdateResolver resolver;

    setUpAll(() {
      // Регистрируем fallback значения для mocktail
      registerFallbackValue(UpdateSearchData(
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay],
        appVersion: Version.parse('1.0.0'),
        displayTarget: UpdateViewTarget.any,
        appStatus: AppStatus.active,
        locale: UpdateLocale.any,
        currentDate: DateTime.now(),
        localReleaseDate: null,
        updateReleaseDate: null,
        appUpdateDate: null,
        appInstallDate: null,
        segmentationPointer: 0,
        rolloutPointer: 0,
        appName: 'Test',
        appPackageName: 'com.test',
        customParams: null,
      ));

      registerFallbackValue(<UpdateRuleConfig<UpdateAppSettingsConfig>>[]);
      registerFallbackValue(<UpdateRuleConfig<UpdateContentConfig>>[]);
      registerFallbackValue(<UpdateRuleConfig<UpdateSettingsConfig>>[]);

      registerFallbackValue(const UpdateContentData(
        updateUrl: 'https://example.com',
        title: 'Title',
        description: 'Description',
        releaseNotesTitle: 'Release Notes',
        releaseNotes: null,
        skipButton: 'Skip',
        postponeButton: 'Later',
        updateButton: 'Update',
        customParams: null,
      ));

      registerFallbackValue(UpdateData(
        version: Version.parse('1.0.0'),
        date: DateTime.now(),
        sourceName: UpdateSourceName.googlePlay,
        platform: UpdatePlatform.android,
        contentRules: [],
        settingsRules: [],
        appSettingsRules: [],
        customParams: null,
      ));
    });

    setUp(() {
      mockRuleResolver = _MockUpdateRuleResolver();
      mockContentInterpolator = _MockUpdateContentInterpolator();
      resolver = UpdateResolver(
        ruleResolver: mockRuleResolver,
        contentInterpolator: mockContentInterpolator,
      );
    });

    group('resolve', () {
      test('успешно резолвит все компоненты в UpdateResult', () {
        // Arrange
        final searchData = UpdateSearchData(
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appVersion: Version.parse('1.0.0'),
          displayTarget: UpdateViewTarget.any,
          appStatus: null, // Тестируем что будет установлен из appSettings
          locale: UpdateLocale.any,
          currentDate: DateTime(2024, 10, 15),
          localReleaseDate: DateTime(2024, 10),
          updateReleaseDate: DateTime(2024, 10, 10),
          appUpdateDate: null,
          appInstallDate: null,
          segmentationPointer: 0.3,
          rolloutPointer: 0.5,
          appName: 'Test App',
          appPackageName: 'com.test.app',
          customParams: null,
        );

        final updateData = UpdateData(
          version: Version.parse('2.0.0'),
          date: DateTime(2024, 10, 10),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
          contentRules: [
            const UpdateRuleConfig(
              data: UpdateContentConfig(title: 'Raw Title'),
            ),
          ],
          settingsRules: [
            const UpdateRuleConfig(
              data: UpdateSettingsConfig(shouldShow: true),
            ),
          ],
          appSettingsRules: [
            const UpdateRuleConfig(
              data: UpdateAppSettingsConfig(appStatus: AppStatus.active),
            ),
          ],
          customParams: {'test': 'value'},
        );

        const mockAppSettingsConfig = UpdateAppSettingsConfig(
          appStatus: AppStatus.outdated,
          customParams: {'app': 'settings'},
        );

        const mockContentConfig = UpdateContentConfig(
          updateUrl: 'https://example.com',
          title: 'Update Available',
          description: 'New version available',
          releaseNotesTitle: "What's New",
          skipButton: 'Skip',
          postponeButton: 'Later',
          updateButton: 'Update',
        );

        const mockSettingsConfig = UpdateSettingsConfig(
          shouldShow: true,
          canSkip: false,
          canPostpone: true,
          skipReleaseDelay: Duration(hours: 24),
          skipAllReleasesDelay: Duration(days: 7),
          postponeReleaseDelay: Duration(hours: 12),
          postponeAllReleasesDelay: Duration(days: 3),
        );

        const mockInterpolatedContent = UpdateContentData(
          updateUrl: 'https://example.com',
          title: 'Update Available - Interpolated',
          description: 'New version available - Interpolated',
          releaseNotesTitle: "What's New",
          releaseNotes: null,
          skipButton: 'Skip',
          postponeButton: 'Later',
          updateButton: 'Update',
          customParams: null,
        );

        // Setup mocks
        when(() => mockRuleResolver.resolve<UpdateAppSettingsConfig>(
              searchData: any(named: 'searchData'),
              rules: any(named: 'rules'),
            )).thenReturn(mockAppSettingsConfig);
        when(() => mockRuleResolver.resolve<UpdateContentConfig>(
              searchData: any(named: 'searchData'),
              rules: any(named: 'rules'),
            )).thenReturn(mockContentConfig);
        when(() => mockRuleResolver.resolve<UpdateSettingsConfig>(
              searchData: any(named: 'searchData'),
              rules: any(named: 'rules'),
            )).thenReturn(mockSettingsConfig);
        when(() => mockContentInterpolator.interpolate(
              updateContent: any(named: 'updateContent'),
              searchData: any(named: 'searchData'),
              updateData: any(named: 'updateData'),
            )).thenReturn(mockInterpolatedContent);

        // Act
        final result = resolver.resolve(
          updateData: updateData,
          searchData: searchData,
        );

        // Assert
        expect(result, isA<UpdateResult>());
        expect(result.updateStatus, isA<UpdateFoundStatus>());
        expect(
          result.searchData?.appStatus,
          AppStatus.outdated,
        ); // Обновлен из appSettings

        // ignore: avoid-non-null-assertion
        final update = result.update!;
        expect(update.version, Version.parse('2.0.0'));
        expect(update.date, DateTime(2024, 10, 10));
        expect(update.sourceName, UpdateSourceName.googlePlay);
        expect(update.platform, UpdatePlatform.android);
        expect(update.customParams?['test'], 'value');

        // Проверяем что content интерполировался
        expect(update.content.title, 'Update Available - Interpolated');
        expect(
          update.content.description,
          'New version available - Interpolated',
        );

        // Проверяем rawContent (до интерполяции)
        expect(update.rawContent.title, 'Update Available');
        expect(update.rawContent.description, 'New version available');

        // Проверяем settings
        expect(update.settings.shouldShow, true);
        expect(update.settings.canSkip, false);

        // Проверяем appSettings
        expect(update.appSettings.appStatus, AppStatus.outdated);
        expect(update.appSettings.customParams?['app'], 'settings');
      });

      test('не изменяет appStatus если он уже установлен в searchData', () {
        // Arrange
        final searchData = UpdateSearchData(
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appVersion: Version.parse('1.0.0'),
          displayTarget: UpdateViewTarget.any,
          appStatus: AppStatus.unsupported, // Уже установлен
          locale: UpdateLocale.any,
          currentDate: DateTime(2024, 10, 15),
          localReleaseDate: null,
          updateReleaseDate: null,
          appUpdateDate: null,
          appInstallDate: null,
          segmentationPointer: 0.3,
          rolloutPointer: 0.5,
          appName: 'Test App',
          appPackageName: 'com.test.app',
          customParams: null,
        );

        final updateData = UpdateData(
          version: Version.parse('2.0.0'),
          date: DateTime(2024, 10, 10),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
          contentRules: [const UpdateRuleConfig(data: UpdateContentConfig())],
          settingsRules: [
            const UpdateRuleConfig(
              data: UpdateSettingsConfig(
                shouldShow: true,
                canSkip: false,
                canPostpone: true,
                skipReleaseDelay: Duration(hours: 24),
                skipAllReleasesDelay: Duration(days: 7),
                postponeReleaseDelay: Duration(hours: 12),
                postponeAllReleasesDelay: Duration(days: 3),
              ),
            ),
          ],
          appSettingsRules: [
            const UpdateRuleConfig(data: UpdateAppSettingsConfig()),
          ],
          customParams: null,
        );

        // Setup mocks
        when(() => mockRuleResolver.resolve<UpdateAppSettingsConfig>(
              searchData: any(named: 'searchData'),
              rules: any(named: 'rules'),
            )).thenReturn(
          const UpdateAppSettingsConfig(appStatus: AppStatus.active),
        );
        when(() => mockRuleResolver.resolve<UpdateContentConfig>(
              searchData: any(named: 'searchData'),
              rules: any(named: 'rules'),
            )).thenReturn(const UpdateContentConfig.byRequired(
          updateUrl: 'https://example.com',
          title: 'Test Title',
          description: 'Test Description',
          releaseNotesTitle: 'Release Notes',
          releaseNotes: null,
          skipButton: 'Skip',
          postponeButton: 'Later',
          updateButton: 'Update',
          customParams: null,
        ));
        when(() => mockRuleResolver.resolve<UpdateSettingsConfig>(
              searchData: any(named: 'searchData'),
              rules: any(named: 'rules'),
            )).thenReturn(const UpdateSettingsConfig(
          shouldShow: true,
          canSkip: false,
          canPostpone: true,
          skipReleaseDelay: Duration(hours: 24),
          skipAllReleasesDelay: Duration(days: 7),
          postponeReleaseDelay: Duration(hours: 12),
          postponeAllReleasesDelay: Duration(days: 3),
        ));

        // Setup mock for interpolator
        when(() => mockContentInterpolator.interpolate(
                  updateContent: any(named: 'updateContent'),
                  searchData: any(named: 'searchData'),
                  updateData: any(named: 'updateData'),
                ))
            .thenAnswer((invocation) =>
                invocation.namedArguments[#updateContent] as UpdateContentData);

        // Act
        final result = resolver.resolve(
          updateData: updateData,
          searchData: searchData,
        );

        // Assert - appStatus должен остаться unsupported (исходный)
        expect(result.searchData?.appStatus, AppStatus.unsupported);
      });

      test('правильно передает все данные в зависимости', () {
        // Arrange
        final capturedSearchDataForAppSettings = <UpdateSearchData>[];
        final capturedSearchDataForContent = <UpdateSearchData>[];
        final capturedSearchDataForSettings = <UpdateSearchData>[];
        final capturedInterpolateParams = <Map<String, dynamic>>[];

        // Setup мок для app settings с захватом параметров
        when(() => mockRuleResolver.resolve<UpdateAppSettingsConfig>(
              searchData: any(named: 'searchData'),
              rules: any(named: 'rules'),
            )).thenAnswer((invocation) {
          final searchData =
              invocation.namedArguments[#searchData] as UpdateSearchData;
          capturedSearchDataForAppSettings.add(searchData);

          return const UpdateAppSettingsConfig(appStatus: AppStatus.active);
        });

        // Setup мок для content с захватом параметров
        when(() => mockRuleResolver.resolve<UpdateContentConfig>(
              searchData: any(named: 'searchData'),
              rules: any(named: 'rules'),
            )).thenAnswer((invocation) {
          final searchData =
              invocation.namedArguments[#searchData] as UpdateSearchData;
          capturedSearchDataForContent.add(searchData);

          return const UpdateContentConfig.byRequired(
            updateUrl: 'https://example.com',
            title: 'Test Content',
            description: 'Description',
            releaseNotesTitle: 'Release Notes',
            releaseNotes: null,
            skipButton: 'Skip',
            postponeButton: 'Later',
            updateButton: 'Update',
            customParams: null,
          );
        });

        // Setup мок для settings с захватом параметров
        when(() => mockRuleResolver.resolve<UpdateSettingsConfig>(
              searchData: any(named: 'searchData'),
              rules: any(named: 'rules'),
            )).thenAnswer((invocation) {
          final searchData =
              invocation.namedArguments[#searchData] as UpdateSearchData;
          capturedSearchDataForSettings.add(searchData);

          return const UpdateSettingsConfig(
            shouldShow: false,
            canSkip: true,
            canPostpone: false,
            skipReleaseDelay: Duration(hours: 24),
            skipAllReleasesDelay: Duration(days: 7),
            postponeReleaseDelay: Duration(hours: 12),
            postponeAllReleasesDelay: Duration(days: 3),
          );
        });

        // Setup мок для interpolator с захватом параметров
        when(() => mockContentInterpolator.interpolate(
              updateContent: any(named: 'updateContent'),
              searchData: any(named: 'searchData'),
              updateData: any(named: 'updateData'),
            )).thenAnswer((invocation) {
          final updateContent =
              invocation.namedArguments[#updateContent] as UpdateContentData;
          final searchData =
              invocation.namedArguments[#searchData] as UpdateSearchData;
          final updateData =
              invocation.namedArguments[#updateData] as UpdateData;
          capturedInterpolateParams.add({
            'updateContent': updateContent,
            'searchData': searchData,
            'updateData': updateData,
          });

          return const UpdateContentData(
            updateUrl: 'https://example.com',
            title: 'Interpolated',
            description: 'Description',
            releaseNotesTitle: 'Release Notes',
            releaseNotes: null,
            skipButton: 'Skip',
            postponeButton: 'Later',
            updateButton: 'Update',
            customParams: null,
          );
        });

        final searchData = UpdateSearchData(
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appVersion: Version.parse('1.0.0'),
          displayTarget: UpdateViewTarget.any,
          appStatus: null,
          locale: UpdateLocale.any,
          currentDate: DateTime(2024, 10, 15),
          localReleaseDate: null,
          updateReleaseDate: null,
          appUpdateDate: null,
          appInstallDate: null,
          segmentationPointer: 0.3,
          rolloutPointer: 0.5,
          appName: 'Test App',
          appPackageName: 'com.test.app',
          customParams: null,
        );

        final updateData = UpdateData(
          version: Version.parse('2.0.0'),
          date: DateTime(2024, 10, 10),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
          contentRules: [const UpdateRuleConfig(data: UpdateContentConfig())],
          settingsRules: [
            const UpdateRuleConfig(
              data: UpdateSettingsConfig(
                shouldShow: true,
                canSkip: false,
                canPostpone: true,
                skipReleaseDelay: Duration(hours: 24),
                skipAllReleasesDelay: Duration(days: 7),
                postponeReleaseDelay: Duration(hours: 12),
                postponeAllReleasesDelay: Duration(days: 3),
              ),
            ),
          ],
          appSettingsRules: [
            const UpdateRuleConfig(data: UpdateAppSettingsConfig()),
          ],
          customParams: null,
        );

        // Act
        final result = resolver.resolve(
          updateData: updateData,
          searchData: searchData,
        );

        // Assert
        // Проверяем что ruleResolver вызывался с правильными данными
        expect(capturedSearchDataForAppSettings, hasLength(1));
        expect(
          capturedSearchDataForAppSettings.firstOrNull?.appStatus,
          isNull,
        ); // Исходные данные

        expect(capturedSearchDataForContent, hasLength(1));
        expect(
          capturedSearchDataForContent.firstOrNull?.appStatus,
          AppStatus.active,
        ); // Обновленные

        expect(capturedSearchDataForSettings, hasLength(1));
        expect(
          capturedSearchDataForSettings.firstOrNull?.appStatus,
          AppStatus.active,
        ); // Обновленные

        // Проверяем что interpolator получил правильные параметры
        expect(capturedInterpolateParams, hasLength(1));
        final interpolateParams = capturedInterpolateParams.firstOrNull;
        final receivedUpdateContent =
            interpolateParams?['updateContent'] as UpdateContentData;
        final receivedSearchData =
            interpolateParams?['searchData'] as UpdateSearchData;
        final receivedUpdateData =
            interpolateParams?['updateData'] as UpdateData;

        expect(
          receivedUpdateContent.title,
          'Test Content',
        ); // От content resolver
        expect(receivedSearchData.appStatus, AppStatus.active); // Обновленный
        expect(receivedUpdateData.version, Version.parse('2.0.0'));

        // Проверяем финальный результат
        expect(result.update?.content.title, 'Interpolated');
        expect(result.update?.rawContent.title, 'Test Content');
      });
    });

    group('edge cases', () {
      test('обрабатывает пустые customParams', () {
        final searchData = UpdateSearchData(
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appVersion: Version.parse('1.0.0'),
          displayTarget: UpdateViewTarget.any,
          appStatus: AppStatus.active,
          locale: UpdateLocale.any,
          currentDate: DateTime(2024, 10, 15),
          localReleaseDate: null,
          updateReleaseDate: null,
          appUpdateDate: null,
          appInstallDate: null,
          segmentationPointer: 0.3,
          rolloutPointer: 0.5,
          appName: 'App',
          appPackageName: 'com.app',
          customParams: null,
        );

        final updateData = UpdateData(
          version: Version.parse('2.0.0'),
          date: DateTime(2024, 10, 10),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
          contentRules: [const UpdateRuleConfig(data: UpdateContentConfig())],
          settingsRules: [
            const UpdateRuleConfig(
              data: UpdateSettingsConfig(
                shouldShow: true,
                canSkip: false,
                canPostpone: true,
                skipReleaseDelay: Duration(hours: 24),
                skipAllReleasesDelay: Duration(days: 7),
                postponeReleaseDelay: Duration(hours: 12),
                postponeAllReleasesDelay: Duration(days: 3),
              ),
            ),
          ],
          appSettingsRules: [
            const UpdateRuleConfig(data: UpdateAppSettingsConfig()),
          ],
          customParams: null, // null customParams
        );

        when(() => mockRuleResolver.resolve<UpdateAppSettingsConfig>(
              searchData: any(named: 'searchData'),
              rules: any(named: 'rules'),
            )).thenReturn(
          const UpdateAppSettingsConfig(appStatus: AppStatus.active),
        );
        when(() => mockRuleResolver.resolve<UpdateContentConfig>(
              searchData: any(named: 'searchData'),
              rules: any(named: 'rules'),
            )).thenReturn(const UpdateContentConfig.byRequired(
          updateUrl: 'https://example.com',
          title: 'Title',
          description: 'Description',
          releaseNotesTitle: 'Release Notes',
          releaseNotes: null,
          skipButton: 'Skip',
          postponeButton: 'Later',
          updateButton: 'Update',
          customParams: null,
        ));
        when(() => mockRuleResolver.resolve<UpdateSettingsConfig>(
              searchData: any(named: 'searchData'),
              rules: any(named: 'rules'),
            )).thenReturn(const UpdateSettingsConfig(
          shouldShow: true,
          canSkip: false,
          canPostpone: true,
          skipReleaseDelay: Duration(hours: 24),
          skipAllReleasesDelay: Duration(days: 7),
          postponeReleaseDelay: Duration(hours: 12),
          postponeAllReleasesDelay: Duration(days: 3),
        ));

        // Setup mock for interpolator
        when(() => mockContentInterpolator.interpolate(
                  updateContent: any(named: 'updateContent'),
                  searchData: any(named: 'searchData'),
                  updateData: any(named: 'updateData'),
                ))
            .thenAnswer((invocation) =>
                invocation.namedArguments[#updateContent] as UpdateContentData);

        final result = resolver.resolve(
          updateData: updateData,
          searchData: searchData,
        );

        expect(result.update?.customParams, isNull);
      });

      test('обрабатывает минимальные конфиги', () {
        final searchData = UpdateSearchData(
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appVersion: Version.parse('1.0.0'),
          displayTarget: UpdateViewTarget.any,
          appStatus: AppStatus.active,
          locale: UpdateLocale.any,
          currentDate: DateTime(2024, 10, 15),
          localReleaseDate: null,
          updateReleaseDate: null,
          appUpdateDate: null,
          appInstallDate: null,
          segmentationPointer: 0,
          rolloutPointer: 0,
          appName: '',
          appPackageName: '',
          customParams: null,
        );

        final updateData = UpdateData(
          version: Version.parse('1.0.1'),
          date: DateTime(2024, 10, 10),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
          contentRules: [const UpdateRuleConfig(data: UpdateContentConfig())],
          settingsRules: [
            const UpdateRuleConfig(
              data: UpdateSettingsConfig(
                shouldShow: true,
                canSkip: false,
                canPostpone: true,
                skipReleaseDelay: Duration(hours: 24),
                skipAllReleasesDelay: Duration(days: 7),
                postponeReleaseDelay: Duration(hours: 12),
                postponeAllReleasesDelay: Duration(days: 3),
              ),
            ),
          ],
          appSettingsRules: [
            const UpdateRuleConfig(data: UpdateAppSettingsConfig()),
          ],
          customParams: {},
        );

        when(() => mockRuleResolver.resolve<UpdateAppSettingsConfig>(
              searchData: any(named: 'searchData'),
              rules: any(named: 'rules'),
            )).thenReturn(
          const UpdateAppSettingsConfig(appStatus: AppStatus.active),
        );
        when(() => mockRuleResolver.resolve<UpdateContentConfig>(
              searchData: any(named: 'searchData'),
              rules: any(named: 'rules'),
            )).thenReturn(const UpdateContentConfig.byRequired(
          updateUrl: 'https://example.com',
          title: 'Title',
          description: 'Description',
          releaseNotesTitle: 'Release Notes',
          releaseNotes: null,
          skipButton: 'Skip',
          postponeButton: 'Later',
          updateButton: 'Update',
          customParams: null,
        ));
        when(() => mockRuleResolver.resolve<UpdateSettingsConfig>(
              searchData: any(named: 'searchData'),
              rules: any(named: 'rules'),
            )).thenReturn(const UpdateSettingsConfig(
          shouldShow: true,
          canSkip: false,
          canPostpone: true,
          skipReleaseDelay: Duration(hours: 24),
          skipAllReleasesDelay: Duration(days: 7),
          postponeReleaseDelay: Duration(hours: 12),
          postponeAllReleasesDelay: Duration(days: 3),
        ));

        // Setup mock for interpolator
        when(() => mockContentInterpolator.interpolate(
                  updateContent: any(named: 'updateContent'),
                  searchData: any(named: 'searchData'),
                  updateData: any(named: 'updateData'),
                ))
            .thenAnswer((invocation) =>
                invocation.namedArguments[#updateContent] as UpdateContentData);

        final result = resolver.resolve(
          updateData: updateData,
          searchData: searchData,
        );

        expect(result.update?.version, Version.parse('1.0.1'));
        expect(result.update?.customParams, isEmpty);
        expect(result.searchData?.appName, '');
        expect(result.searchData?.appPackageName, '');
      });
    });
  });
}
