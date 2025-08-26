part of '../update_rule_resolver_test.dart';

void runSourcesPlatformsMatchingTests() {
  group('UpdateRuleResolver - Sources/Platforms matching', () {
    const resolver = UpdateRuleResolver();

    test('rule platforms == null берёт платформы из search source', () {
      const ruleSource = UpdateSource.custom(UpdateSourceName.custom('storeX'));
      const searchSource = UpdateSource.custom(
          UpdateSourceName.custom('storeX'),
          platforms: [UpdatePlatform.ios]);

      final rules = [
        createTestRule(sources: [ruleSource], title: 'ok'),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(
          sources: [searchSource],
          platform: UpdatePlatform.ios,
          // Платформа iOS должна сматчиться через глобальный source
        ),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test('rule platforms == [] отключает правило', () {
      const ruleSource =
          UpdateSource.custom(UpdateSourceName.custom('storeX'), platforms: []);
      const searchSource = UpdateSource.custom(
          UpdateSourceName.custom('storeX'),
          platforms: [UpdatePlatform.ios]);

      final rules = [
        createTestRule(sources: [ruleSource], title: 'bad'),
      ];

      expect(
        () => resolver.resolve(
            searchData: createTestSearchData(sources: [searchSource]),
            rules: rules),
        throwsA(isA<Exception>()),
      );
    });

    test('UpdateSource.any в правиле матчится без ограничений', () {
      final rules = [
        createTestRule(title: 'ok'),
      ];

      final res = resolver.resolve(
        searchData:
            createTestSearchData(sources: const [UpdateSource.googlePlay]),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test('Mismatch платформы — правило не подходит', () {
      final rules = [
        createTestRule(sources: const [UpdateSource.googlePlay], title: 'bad'),
      ];

      // googlePlay поддерживает android; задаём платформу iOS
      expect(
        () => resolver.resolve(
          searchData: createTestSearchData(
            sources: const [UpdateSource.googlePlay],
            platform: UpdatePlatform.ios,
            // принудительно считаем платформу iOS
          ),
          rules: rules,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('rule platforms == [any] допускает любую платформу', () {
      const ruleSource = UpdateSource.custom(UpdateSourceName.custom('storeX'),
          platforms: [UpdatePlatform.any]);
      const searchSource = UpdateSource.custom(
          UpdateSourceName.custom('storeX'),
          platforms: [UpdatePlatform.windows]);

      final rules = [
        createTestRule(sources: [ruleSource], title: 'ok'),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(sources: [searchSource]),
        rules: rules,
      );
      expect(res.title, 'ok');
    });
  });
}
