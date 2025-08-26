part of '../resolver_test.dart';

// Mock classes для тестирования
class MockUpdateRuleResolver implements UpdateRuleResolver {
  final Map<Type, dynamic> _mockResults = {};

  void mockResolve<T extends Mergeable>(T result) {
    _mockResults[T] = result;
  }

  @override
  T resolve<T extends Mergeable>({
    required UpdateSearchData searchData,
    required List<UpdateRuleConfig<T>> rules,
  }) {
    final result = _mockResults[T] as T?;
    if (result == null) {
      throw Exception('No mock result configured for type $T');
    }
    return result;
  }

  @override
  List<RuleMatcher> get matchers => UpdateRuleResolver.defaultMatchers;
}

class MockUpdateContentInterpolator implements UpdateContentInterpolator {
  UpdateContentData? _mockResult;

  void mockInterpolate(UpdateContentData result) {
    _mockResult = result;
  }

  @override
  UpdateContentData interpolate({
    required UpdateContentData updateContent,
    required UpdateSearchData searchData,
    required UpdateData updateData,
  }) {
    return _mockResult ?? updateContent;
  }

  @override
  Map<String, String> buildInterpolateData({
    required UpdateSearchData searchData,
    required UpdateData updateData,
  }) {
    return const UpdateContentInterpolator().buildInterpolateData(
      searchData: searchData,
      updateData: updateData,
    );
  }

  @override
  String capitalize(String text) {
    return const UpdateContentInterpolator().capitalize(text);
  }
}

void runUpdateResolverTests() {
  group('UpdateResolver', () {
    late MockUpdateRuleResolver mockRuleResolver;
    late MockUpdateContentInterpolator mockContentInterpolator;
    late UpdateResolver resolver;

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
          localReleaseDate: DateTime(2024, 10, 1),
          updateReleaseDate: DateTime(2024, 10, 10),
          customData: null,
        );

        final updateData = UpdateData(
          version: Version.parse('2.0.0'),
          date: DateTime(2024, 10, 10),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
          contentRules: [
            UpdateRuleConfig(data: UpdateContentConfig(title: 'Raw Title')),
          ],
          settingsRules: [
            UpdateRuleConfig(data: UpdateSettingsConfig(shouldShow: true)),
          ],
          appSettingsRules: [
            UpdateRuleConfig(
                data: UpdateAppSettingsConfig(appStatus: AppStatus.active)),
          ],
          customData: {'test': 'value'},
        );

        final mockAppSettingsConfig = UpdateAppSettingsConfig(
          appStatus: AppStatus.outdated,
          customData: {'app': 'settings'},
        );

        final mockContentConfig = UpdateContentConfig(
          updateUrl: Uri.parse('https://example.com'),
          title: 'Update Available',
          description: 'New version available',
          releaseNotesTitle: 'What\'s New',
          releaseNotes: null,
          skipButton: 'Skip',
          postponeButton: 'Later',
          updateButton: 'Update',
        );

        final mockSettingsConfig = UpdateSettingsConfig(
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
          releaseNotesTitle: 'What\'s New',
          releaseNotes: null,
          skipButton: 'Skip',
          postponeButton: 'Later',
          updateButton: 'Update',
          customData: null,
        );

        // Setup mocks
        mockRuleResolver
            .mockResolve<UpdateAppSettingsConfig>(mockAppSettingsConfig);
        mockRuleResolver.mockResolve<UpdateContentConfig>(mockContentConfig);
        mockRuleResolver.mockResolve<UpdateSettingsConfig>(mockSettingsConfig);
        mockContentInterpolator.mockInterpolate(mockInterpolatedContent);

        // Act
        final result = resolver.resolve(
          updateData: updateData,
          searchData: searchData,
        );

        // Assert
        expect(result, isA<UpdateResult>());
        expect(result.updateStatus, isA<UpdateFoundStatus>());
        expect(result.searchData!.appStatus!,
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
          contentRules: [UpdateRuleConfig(data: UpdateContentConfig())],
          settingsRules: [
            UpdateRuleConfig(
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
          appSettingsRules: [UpdateRuleConfig(data: UpdateAppSettingsConfig())],
          customData: null,
        );

        // Setup mocks
        mockRuleResolver.mockResolve<UpdateAppSettingsConfig>(
          UpdateAppSettingsConfig(appStatus: AppStatus.active), // Другой статус
        );
        mockRuleResolver.mockResolve<UpdateContentConfig>(
          UpdateContentConfig.byRequired(
            updateUrl: Uri.parse('https://example.com'),
            title: 'Test Title',
            description: 'Test Description',
            releaseNotesTitle: 'Release Notes',
            releaseNotes: null,
            skipButton: 'Skip',
            postponeButton: 'Later',
            updateButton: 'Update',
            customData: null,
          ),
        );
        mockRuleResolver.mockResolve<UpdateSettingsConfig>(UpdateSettingsConfig(
          shouldShow: true,
          canSkip: false,
          canPostpone: true,
          skipReleaseDelay: Duration(hours: 24),
          skipAllReleasesDelay: Duration(days: 7),
          postponeReleaseDelay: Duration(hours: 12),
          postponeAllReleasesDelay: Duration(days: 3),
        ));

        // Act
        final result = resolver.resolve(
          updateData: updateData,
          searchData: searchData,
        );

        // Assert - appStatus должен остаться unsupported (исходный)
        expect(result.searchData!.appStatus!, AppStatus.unsupported);
      });

      test('правильно передает все данные в зависимости', () {
        // Arrange
        var capturedSearchDataForAppSettings = <UpdateSearchData>[];
        var capturedSearchDataForContent = <UpdateSearchData>[];
        var capturedSearchDataForSettings = <UpdateSearchData>[];
        var capturedInterpolateParams = <Map<String, dynamic>>[];

        final testRuleResolver = TestUpdateRuleResolver(
          onResolveAppSettings: (searchData, rules) {
            capturedSearchDataForAppSettings.add(searchData);
            return UpdateAppSettingsConfig(appStatus: AppStatus.active);
          },
          onResolveContent: (searchData, rules) {
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
          },
          onResolveSettings: (searchData, rules) {
            capturedSearchDataForSettings.add(searchData);
            return UpdateSettingsConfig(
              shouldShow: false,
              canSkip: true,
              canPostpone: false,
              skipReleaseDelay: Duration(hours: 24),
              skipAllReleasesDelay: Duration(days: 7),
              postponeReleaseDelay: Duration(hours: 12),
              postponeAllReleasesDelay: Duration(days: 3),
            );
          },
        );

        final testContentInterpolator = TestUpdateContentInterpolator(
          onInterpolate: (updateContent, searchData, updateData) {
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
          },
        );

        final testResolver = UpdateResolver(
          ruleResolver: testRuleResolver,
          contentInterpolator: testContentInterpolator,
        );

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
          contentRules: [UpdateRuleConfig(data: UpdateContentConfig())],
          settingsRules: [
            UpdateRuleConfig(
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
          appSettingsRules: [UpdateRuleConfig(data: UpdateAppSettingsConfig())],
          customData: null,
        );

        // Act
        final result = testResolver.resolve(
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
          contentRules: [UpdateRuleConfig(data: UpdateContentConfig())],
          settingsRules: [
            UpdateRuleConfig(
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
          appSettingsRules: [UpdateRuleConfig(data: UpdateAppSettingsConfig())],
          customData: null, // null customData
        );

        mockRuleResolver.mockResolve<UpdateAppSettingsConfig>(
          UpdateAppSettingsConfig(appStatus: AppStatus.active),
        );
        mockRuleResolver.mockResolve<UpdateContentConfig>(
          UpdateContentConfig.byRequired(
            updateUrl: Uri.parse('https://example.com'),
            title: 'Title',
            description: 'Description',
            releaseNotesTitle: 'Release Notes',
            releaseNotes: null,
            skipButton: 'Skip',
            postponeButton: 'Later',
            updateButton: 'Update',
            customData: null,
          ),
        );
        mockRuleResolver.mockResolve<UpdateSettingsConfig>(UpdateSettingsConfig(
          shouldShow: true,
          canSkip: false,
          canPostpone: true,
          skipReleaseDelay: Duration(hours: 24),
          skipAllReleasesDelay: Duration(days: 7),
          postponeReleaseDelay: Duration(hours: 12),
          postponeAllReleasesDelay: Duration(days: 3),
        ));

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
          rolloutPointer: 0.0,
          segmentationPointer: 0.0,
          localReleaseDate: null,
          updateReleaseDate: null,
          customData: null,
        );

        final updateData = UpdateData(
          version: Version.parse('1.0.1'),
          date: DateTime(2024, 10, 10),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
          contentRules: [UpdateRuleConfig(data: UpdateContentConfig())],
          settingsRules: [
            UpdateRuleConfig(
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
          appSettingsRules: [UpdateRuleConfig(data: UpdateAppSettingsConfig())],
          customData: {},
        );

        mockRuleResolver.mockResolve<UpdateAppSettingsConfig>(
          UpdateAppSettingsConfig(appStatus: AppStatus.active),
        );
        mockRuleResolver.mockResolve<UpdateContentConfig>(
          UpdateContentConfig.byRequired(
            updateUrl: Uri.parse('https://example.com'),
            title: 'Title',
            description: 'Description',
            releaseNotesTitle: 'Release Notes',
            releaseNotes: null,
            skipButton: 'Skip',
            postponeButton: 'Later',
            updateButton: 'Update',
            customData: null,
          ),
        );
        mockRuleResolver.mockResolve<UpdateSettingsConfig>(UpdateSettingsConfig(
          shouldShow: true,
          canSkip: false,
          canPostpone: true,
          skipReleaseDelay: Duration(hours: 24),
          skipAllReleasesDelay: Duration(days: 7),
          postponeReleaseDelay: Duration(hours: 12),
          postponeAllReleasesDelay: Duration(days: 3),
        ));

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

// Тестовые реализации для проверки передачи параметров
class TestUpdateRuleResolver implements UpdateRuleResolver {
  final UpdateAppSettingsConfig Function(
          UpdateSearchData, List<UpdateRuleConfig<UpdateAppSettingsConfig>>)?
      onResolveAppSettings;
  final UpdateContentConfig Function(
          UpdateSearchData, List<UpdateRuleConfig<UpdateContentConfig>>)?
      onResolveContent;
  final UpdateSettingsConfig Function(
          UpdateSearchData, List<UpdateRuleConfig<UpdateSettingsConfig>>)?
      onResolveSettings;

  TestUpdateRuleResolver({
    this.onResolveAppSettings,
    this.onResolveContent,
    this.onResolveSettings,
  });

  @override
  T resolve<T extends Mergeable>({
    required UpdateSearchData searchData,
    required List<UpdateRuleConfig<T>> rules,
  }) {
    if (T == UpdateAppSettingsConfig) {
      return onResolveAppSettings?.call(searchData,
          rules as List<UpdateRuleConfig<UpdateAppSettingsConfig>>) as T;
    } else if (T == UpdateContentConfig) {
      return onResolveContent?.call(
              searchData, rules as List<UpdateRuleConfig<UpdateContentConfig>>)
          as T;
    } else if (T == UpdateSettingsConfig) {
      return onResolveSettings?.call(
              searchData, rules as List<UpdateRuleConfig<UpdateSettingsConfig>>)
          as T;
    }
    throw UnimplementedError('Type $T not handled in test');
  }

  @override
  List<RuleMatcher> get matchers => UpdateRuleResolver.defaultMatchers;
}

class TestUpdateContentInterpolator implements UpdateContentInterpolator {
  final UpdateContentData Function(
      UpdateContentData, UpdateSearchData, UpdateData)? onInterpolate;

  TestUpdateContentInterpolator({this.onInterpolate});

  @override
  UpdateContentData interpolate({
    required UpdateContentData updateContent,
    required UpdateSearchData searchData,
    required UpdateData updateData,
  }) {
    return onInterpolate?.call(updateContent, searchData, updateData) ??
        updateContent;
  }

  @override
  Map<String, String> buildInterpolateData({
    required UpdateSearchData searchData,
    required UpdateData updateData,
  }) {
    return {};
  }

  @override
  String capitalize(String text) => text;
}
