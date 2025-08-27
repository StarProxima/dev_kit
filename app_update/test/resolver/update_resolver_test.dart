import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_semver/pub_semver.dart';

// Mock classes
class MockUpdateRuleResolver extends Mock implements UpdateRuleResolver {}

class MockUpdateContentInterpolator extends Mock
    implements UpdateContentInterpolator {}

void main() {
  group('UpdateResolver', () {
    late MockUpdateRuleResolver mockRuleResolver;
    late MockUpdateContentInterpolator mockContentInterpolator;
    late UpdateResolver resolver;

    setUpAll(() {
      // Регистрируем fallback значения для mocktail
      registerFallbackValue(UpdateSearchData(
        currentDate: DateTime.now(),
        localVersion: Version.parse('1.0.0'),
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay],
        appName: 'Test',
        appPackageName: 'com.test',
        appStatus: AppStatus.active,
        locale: UpdateLocale.any,
        displayTarget: UpdateViewTarget.any,
        rolloutPointer: 0,
        segmentationPointer: 0,
        localReleaseDate: null,
        updateReleaseDate: null,
        customData: null,
      ));

      registerFallbackValue(<UpdateRuleConfig<UpdateAppSettingsConfig>>[]);
      registerFallbackValue(<UpdateRuleConfig<UpdateContentConfig>>[]);
      registerFallbackValue(<UpdateRuleConfig<UpdateSettingsConfig>>[]);

      registerFallbackValue(UpdateContentData(
        updateUrl: Uri.parse('https://example.com'),
        title: 'Title',
        description: 'Description',
        releaseNotesTitle: 'Release Notes',
        releaseNotes: null,
        skipButton: 'Skip',
        postponeButton: 'Later',
        updateButton: 'Update',
        customData: null,
      ));

      registerFallbackValue(UpdateData(
        version: Version.parse('1.0.0'),
        date: DateTime.now(),
        sourceName: UpdateSourceName.googlePlay,
        platform: UpdatePlatform.android,
        contentRules: [],
        settingsRules: [],
        appSettingsRules: [],
        customData: null,
      ));
    });

    setUp(() {
      mockRuleResolver = MockUpdateRuleResolver();
      mockContentInterpolator = MockUpdateContentInterpolator();
      resolver = UpdateResolver(
        ruleResolver: mockRuleResolver,
        contentInterpolator: mockContentInterpolator,
      );
    });

    group('resolve', () {
      test('успешно резолвит все компоненты в UpdateResult', () {
        // Arrange
        final searchData = UpdateSearchData(
          currentDate: DateTime(2024, 10, 15),
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appName: 'Test App',
          appPackageName: 'com.test.app',
          appStatus: null, // Тестируем что будет установлен из appSettings
          locale: UpdateLocale.any,
          displayTarget: UpdateViewTarget.any,
          rolloutPointer: 0.5,
          segmentationPointer: 0.3,
          localReleaseDate: DateTime(2024, 10),
          updateReleaseDate: DateTime(2024, 10, 10),
          customData: null,
        );

        final updateData = UpdateData(
          version: Version.parse('2.0.0'),
          date: DateTime(2024, 10, 10),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
          contentRules: [
            const UpdateRuleConfig(
                data: UpdateContentConfig(title: 'Raw Title')),
          ],
          settingsRules: [
            const UpdateRuleConfig(
                data: UpdateSettingsConfig(shouldShow: true)),
          ],
          appSettingsRules: [
            const UpdateRuleConfig(
                data: UpdateAppSettingsConfig(appStatus: AppStatus.active)),
          ],
          customData: {'test': 'value'},
        );

        const mockAppSettingsConfig = UpdateAppSettingsConfig(
          appStatus: AppStatus.outdated,
          customData: {'app': 'settings'},
        );

        final mockContentConfig = UpdateContentConfig(
          updateUrl: Uri.parse('https://example.com'),
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

        final mockInterpolatedContent = UpdateContentData(
          updateUrl: Uri.parse('https://example.com'),
          title: 'Update Available - Interpolated',
          description: 'New version available - Interpolated',
          releaseNotesTitle: "What's New",
          releaseNotes: null,
          skipButton: 'Skip',
          postponeButton: 'Later',
          updateButton: 'Update',
          customData: null,
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
        expect(result.searchData!.appStatus,
            AppStatus.outdated); // Обновлен из appSettings

        final update = result.update!;
        expect(update.version, Version.parse('2.0.0'));
        expect(update.date, DateTime(2024, 10, 10));
        expect(update.sourceName, UpdateSourceName.googlePlay);
        expect(update.platform, UpdatePlatform.android);
        expect(update.customData!['test'], 'value');

        // Проверяем что content интерполировался
        expect(update.content.title, 'Update Available - Interpolated');
        expect(
            update.content.description, 'New version available - Interpolated');

        // Проверяем rawContent (до интерполяции)
        expect(update.rawContent.title, 'Update Available');
        expect(update.rawContent.description, 'New version available');

        // Проверяем settings
        expect(update.settings.shouldShow, true);
        expect(update.settings.canSkip, false);

        // Проверяем appSettings
        expect(update.appSettings.appStatus, AppStatus.outdated);
        expect(update.appSettings.customData!['app'], 'settings');
      });

      test('не изменяет appStatus если он уже установлен в searchData', () {
        // Arrange
        final searchData = UpdateSearchData(
          currentDate: DateTime(2024, 10, 15),
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appName: 'Test App',
          appPackageName: 'com.test.app',
          appStatus: AppStatus.unsupported, // Уже установлен
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
            ))
          ],
          appSettingsRules: [
            const UpdateRuleConfig(data: UpdateAppSettingsConfig())
          ],
          customData: null,
        );

        // Setup mocks
        when(() => mockRuleResolver.resolve<UpdateAppSettingsConfig>(
                  searchData: any(named: 'searchData'),
                  rules: any(named: 'rules'),
                ))
            .thenReturn(
                const UpdateAppSettingsConfig(appStatus: AppStatus.active));
        when(() => mockRuleResolver.resolve<UpdateContentConfig>(
              searchData: any(named: 'searchData'),
              rules: any(named: 'rules'),
            )).thenReturn(UpdateContentConfig.byRequired(
          updateUrl: Uri.parse('https://example.com'),
          title: 'Test Title',
          description: 'Test Description',
          releaseNotesTitle: 'Release Notes',
          releaseNotes: null,
          skipButton: 'Skip',
          postponeButton: 'Later',
          updateButton: 'Update',
          customData: null,
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
        expect(result.searchData!.appStatus, AppStatus.unsupported);
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
          return UpdateContentConfig.byRequired(
            updateUrl: Uri.parse('https://example.com'),
            title: 'Test Content',
            description: 'Description',
            releaseNotesTitle: 'Release Notes',
            releaseNotes: null,
            skipButton: 'Skip',
            postponeButton: 'Later',
            updateButton: 'Update',
            customData: null,
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
          return UpdateContentData(
            updateUrl: Uri.parse('https://example.com'),
            title: 'Interpolated',
            description: 'Description',
            releaseNotesTitle: 'Release Notes',
            releaseNotes: null,
            skipButton: 'Skip',
            postponeButton: 'Later',
            updateButton: 'Update',
            customData: null,
          );
        });

        final searchData = UpdateSearchData(
          currentDate: DateTime(2024, 10, 15),
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appName: 'Test App',
          appPackageName: 'com.test.app',
          appStatus: null,
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
            ))
          ],
          appSettingsRules: [
            const UpdateRuleConfig(data: UpdateAppSettingsConfig())
          ],
          customData: null,
        );

        // Act
        final result = resolver.resolve(
          updateData: updateData,
          searchData: searchData,
        );

        // Assert
        // Проверяем что ruleResolver вызывался с правильными данными
        expect(capturedSearchDataForAppSettings, hasLength(1));
        expect(capturedSearchDataForAppSettings[0].appStatus,
            isNull); // Исходные данные

        expect(capturedSearchDataForContent, hasLength(1));
        expect(capturedSearchDataForContent[0].appStatus,
            AppStatus.active); // Обновленные

        expect(capturedSearchDataForSettings, hasLength(1));
        expect(capturedSearchDataForSettings[0].appStatus,
            AppStatus.active); // Обновленные

        // Проверяем что interpolator получил правильные параметры
        expect(capturedInterpolateParams, hasLength(1));
        final interpolateParams = capturedInterpolateParams[0];
        final receivedUpdateContent =
            interpolateParams['updateContent'] as UpdateContentData;
        final receivedSearchData =
            interpolateParams['searchData'] as UpdateSearchData;
        final receivedUpdateData =
            interpolateParams['updateData'] as UpdateData;

        expect(
            receivedUpdateContent.title, 'Test Content'); // От content resolver
        expect(receivedSearchData.appStatus, AppStatus.active); // Обновленный
        expect(receivedUpdateData.version, Version.parse('2.0.0'));

        // Проверяем финальный результат
        expect(result.update!.content.title, 'Interpolated');
        expect(result.update!.rawContent.title, 'Test Content');
      });
    });

    group('edge cases', () {
      test('обрабатывает пустые customData', () {
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
            ))
          ],
          appSettingsRules: [
            const UpdateRuleConfig(data: UpdateAppSettingsConfig())
          ],
          customData: null, // null customData
        );

        when(() => mockRuleResolver.resolve<UpdateAppSettingsConfig>(
                  searchData: any(named: 'searchData'),
                  rules: any(named: 'rules'),
                ))
            .thenReturn(
                const UpdateAppSettingsConfig(appStatus: AppStatus.active));
        when(() => mockRuleResolver.resolve<UpdateContentConfig>(
              searchData: any(named: 'searchData'),
              rules: any(named: 'rules'),
            )).thenReturn(UpdateContentConfig.byRequired(
          updateUrl: Uri.parse('https://example.com'),
          title: 'Title',
          description: 'Description',
          releaseNotesTitle: 'Release Notes',
          releaseNotes: null,
          skipButton: 'Skip',
          postponeButton: 'Later',
          updateButton: 'Update',
          customData: null,
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

        expect(result.update!.customData, isNull);
      });

      test('обрабатывает минимальные конфиги', () {
        final searchData = UpdateSearchData(
          currentDate: DateTime(2024, 10, 15),
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appName: '',
          appPackageName: '',
          appStatus: AppStatus.active,
          locale: UpdateLocale.any,
          displayTarget: UpdateViewTarget.any,
          rolloutPointer: 0,
          segmentationPointer: 0,
          localReleaseDate: null,
          updateReleaseDate: null,
          customData: null,
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
            ))
          ],
          appSettingsRules: [
            const UpdateRuleConfig(data: UpdateAppSettingsConfig())
          ],
          customData: {},
        );

        when(() => mockRuleResolver.resolve<UpdateAppSettingsConfig>(
                  searchData: any(named: 'searchData'),
                  rules: any(named: 'rules'),
                ))
            .thenReturn(
                const UpdateAppSettingsConfig(appStatus: AppStatus.active));
        when(() => mockRuleResolver.resolve<UpdateContentConfig>(
              searchData: any(named: 'searchData'),
              rules: any(named: 'rules'),
            )).thenReturn(UpdateContentConfig.byRequired(
          updateUrl: Uri.parse('https://example.com'),
          title: 'Title',
          description: 'Description',
          releaseNotesTitle: 'Release Notes',
          releaseNotes: null,
          skipButton: 'Skip',
          postponeButton: 'Later',
          updateButton: 'Update',
          customData: null,
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

        expect(result.update!.version, Version.parse('1.0.1'));
        expect(result.update!.customData, isEmpty);
        expect(result.searchData!.appName, '');
        expect(result.searchData!.appPackageName, '');
      });
    });
  });
}
