import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

import 'helpers/resolver_test_helpers.dart';

void main() {
  group('UpdateRuleResolver - PlatformMatcher tests', () {
    const resolver = UpdateRuleResolver();

    group('Базовый матчинг платформ', () {
      test('Android платформа матчится с Android правилом', () {
        final rules = [
          createTestRule(
            platforms: const [UpdatePlatform.android],
            title: 'Android Rule',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.android),
          rules: rules,
        );

        expect(res.title, 'Android Rule');
      });

      test('iOS платформа матчится с iOS правилом', () {
        final rules = [
          createTestRule(
            platforms: const [UpdatePlatform.ios],
            title: 'iOS Rule',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.ios),
          rules: rules,
        );

        expect(res.title, 'iOS Rule');
      });

      test('macOS платформа матчится с macOS правилом', () {
        final rules = [
          createTestRule(
            platforms: const [UpdatePlatform.macos],
            title: 'macOS Rule',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.macos),
          rules: rules,
        );

        expect(res.title, 'macOS Rule');
      });

      test('Windows платформа матчится с Windows правилом', () {
        final rules = [
          createTestRule(
            platforms: const [UpdatePlatform.windows],
            title: 'Windows Rule',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.windows),
          rules: rules,
        );

        expect(res.title, 'Windows Rule');
      });

      test('Linux платформа матчится с Linux правилом', () {
        final rules = [
          createTestRule(
            platforms: const [UpdatePlatform.linux],
            title: 'Linux Rule',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.linux),
          rules: rules,
        );

        expect(res.title, 'Linux Rule');
      });

      test('Web платформа матчится с Web правилом', () {
        final rules = [
          createTestRule(
            platforms: const [UpdatePlatform.web],
            title: 'Web Rule',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.web),
          rules: rules,
        );

        expect(res.title, 'Web Rule');
      });
    });

    group('Множественные платформы в правилах', () {
      test('Правило с несколькими платформами матчит одну из них', () {
        final rules = [
          createTestRule(
            platforms: const [
              UpdatePlatform.android,
              UpdatePlatform.ios,
              UpdatePlatform.macos,
            ],
            title: 'Mobile+Desktop Rule',
          ),
        ];

        // Проверяем Android
        final androidRes = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.android),
          rules: rules,
        );
        expect(androidRes.title, 'Mobile+Desktop Rule');

        // Проверяем iOS
        final iosRes = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.ios),
          rules: rules,
        );
        expect(iosRes.title, 'Mobile+Desktop Rule');

        // Проверяем macOS
        final macosRes = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.macos),
          rules: rules,
        );
        expect(macosRes.title, 'Mobile+Desktop Rule');
      });

      test('Правило не матчится если платформы не в списке', () {
        final rules = [
          createTestRule(
            platforms: const [UpdatePlatform.android, UpdatePlatform.ios],
            title: 'Mobile Only',
          ),
        ];

        // Windows не в списке мобильных платформ
        expect(
          () => resolver.resolve(
            searchData: createTestSearchData(platform: UpdatePlatform.windows),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('UpdatePlatform.any поддержка', () {
      test('UpdatePlatform.any в правиле матчит любую платформу', () {
        final rules = [
          createTestRule(
            title: 'Any Platform Rule',
          ),
        ];

        // Проверяем разные платформы
        final platforms = [
          UpdatePlatform.android,
          UpdatePlatform.ios,
          UpdatePlatform.macos,
          UpdatePlatform.windows,
          UpdatePlatform.linux,
          UpdatePlatform.web,
        ];

        for (final platform in platforms) {
          final res = resolver.resolve(
            searchData: createTestSearchData(platform: platform),
            rules: rules,
          );
          expect(res.title, 'Any Platform Rule');
        }
      });

      test('UpdatePlatform.any в правиле имеет высокий приоритет', () {
        final rules = [
          createTestRule(
            platforms: const [UpdatePlatform.android],
            title: 'Android Specific',
          ),
          createTestRule(
            title: 'Any Platform Override',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.android),
          rules: rules,
        );

        // Второе правило (any) должно переопределить первое
        expect(res.title, 'Any Platform Override');
      });

      test('Смешанные платформы с any в одном правиле', () {
        final rules = [
          createTestRule(
            platforms: const [
              UpdatePlatform.android,
              UpdatePlatform.any, // any делает правило универсальным
              UpdatePlatform.ios,
            ],
            title: 'Mixed with Any',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.windows),
          rules: rules,
        );

        expect(res.title, 'Mixed with Any');
      });
    });

    group('Дефолтное поведение (platformIs == null)', () {
      test('null platformIs означает [UpdatePlatform.any]', () {
        final rules = [
          createTestRule(
            // platforms не указаны - должно быть как [UpdatePlatform.any]
            title: 'Default Platform Rule',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.linux),
          rules: rules,
        );

        expect(res.title, 'Default Platform Rule');
      });

      test('пустой список платформ НЕ матчится (блокирует правило)', () {
        final rules = [
          createTestRule(
            platforms: const [], // Пустой список - блокирует правило
            title: 'Empty Platform List Should Fail',
          ),
        ];

        // Пустой список платформ должен блокировать правило
        expect(
          () => resolver.resolve(
            searchData: createTestSearchData(platform: UpdatePlatform.web),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Кастомные платформы', () {
      test('Кастомные платформы матчатся по имени', () {
        const customPlatform1 = UpdatePlatform.custom('myCustomPlatform');
        const customPlatform2 =
            UpdatePlatform.custom('myCustomPlatform'); // То же имя

        final rules = [
          createTestRule(
            platforms: [customPlatform1],
            title: 'Custom Platform Rule',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(platform: customPlatform2),
          rules: rules,
        );

        expect(res.title, 'Custom Platform Rule');
      });

      test('Разные кастомные платформы не матчатся', () {
        const customPlatform1 = UpdatePlatform.custom('platform1');
        const customPlatform2 = UpdatePlatform.custom('platform2');

        final rules = [
          createTestRule(
            platforms: [customPlatform1],
            title: 'Platform1 Only',
          ),
        ];

        expect(
          () => resolver.resolve(
            searchData: createTestSearchData(platform: customPlatform2),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('Кастомная платформа и стандартные в одном правиле', () {
        const customPlatform = UpdatePlatform.custom('embedded');

        final rules = [
          createTestRule(
            platforms: const [
              UpdatePlatform.android,
              UpdatePlatform.ios,
              customPlatform,
            ],
            title: 'Mobile + Custom',
          ),
        ];

        // Проверяем что кастомная платформа работает
        final customRes = resolver.resolve(
          searchData: createTestSearchData(platform: customPlatform),
          rules: rules,
        );
        expect(customRes.title, 'Mobile + Custom');

        // Проверяем что стандартная тоже работает
        final androidRes = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.android),
          rules: rules,
        );
        expect(androidRes.title, 'Mobile + Custom');
      });
    });

    group('Приоритеты и мержинг правил по платформам', () {
      test('Специфичное правило платформы переопределяет общее', () {
        final rules = [
          createTestRule(
            title: 'General Rule',
            description: 'General Description',
          ),
          createTestRule(
            platforms: const [UpdatePlatform.android],
            title: 'Android Specific', // Переопределяем title
            // description остается из первого правила
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.android),
          rules: rules,
        );

        expect(res.title, 'Android Specific');
        expect(res.description, 'General Description'); // Мержинг работает
      });

      test('Несколько специфичных правил мержатся по порядку', () {
        final rules = [
          createTestRule(
            platforms: const [UpdatePlatform.android],
            title: 'Android Title',
            description: 'Android Description',
          ),
          createTestRule(
            platforms: const [UpdatePlatform.android],
            title: 'Android Override', // Переопределяем title
            // description остается
          ),
          createTestRule(
            platforms: const [UpdatePlatform.android],
            description:
                'Final Android Description', // Переопределяем description
            // title остается из предыдущего
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.android),
          rules: rules,
        );

        expect(res.title, 'Android Override');
        expect(res.description, 'Final Android Description');
      });
    });

    group('Интеграция с другими матчерами', () {
      test('PlatformMatcher + LocaleMatcher комбинация', () {
        final rules = [
          createTestRule(
            locales: [UpdateLocale.ru],
            platforms: const [UpdatePlatform.android],
            title: 'Android + Русский',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(
            locale: UpdateLocale.ru,
            platform: UpdatePlatform.android,
          ),
          rules: rules,
        );

        expect(res.title, 'Android + Русский');
      });

      test('PlatformMatcher не проходит - правило блокируется', () {
        final rules = [
          createTestRule(
            locales: [UpdateLocale.ru], // Подходит
            platforms: const [UpdatePlatform.ios],
            title: 'iOS + Русский',
          ),
        ];

        // Платформа Android не подходит под правило iOS
        expect(
          () => resolver.resolve(
            searchData: createTestSearchData(
              // Не подходит
              locale: UpdateLocale.ru, // Подходит
              platform: UpdatePlatform.android,
            ),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('PlatformMatcher + VersionMatcher + SourceMatcher', () {
        final rules = [
          createTestRule(
            sources: const [UpdateSource.googlePlay],
            platforms: const [UpdatePlatform.android],
            versions: [
              UpdateVersionConstraint(
                VersionConstraint.parse('>=1.0.0 <2.0.0'),
              ),
            ],
            title: 'Android + GooglePlay + v1.x',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(
            sources: const [UpdateSource.googlePlay],
            version: '1.5.0',
            platform: UpdatePlatform.android,
          ),
          rules: rules,
        );

        expect(res.title, 'Android + GooglePlay + v1.x');
      });

      test('Все матчеры должны пройти для применения правила', () {
        final rules = [
          createTestRule(
            locales: [UpdateLocale.ru],
            sources: const [UpdateSource.googlePlay],
            platforms: const [UpdatePlatform.android],
            versions: [
              UpdateVersionConstraint(
                VersionConstraint.parse('>=1.0.0 <2.0.0'),
              ),
            ],
            title: 'All Matchers Required',
          ),
        ];

        // Проваливается по платформе
        expect(
          () => resolver.resolve(
            searchData: createTestSearchData(
              locale: UpdateLocale.ru,
              // Не подходит
              sources: const [UpdateSource.googlePlay],
              version: '1.5.0',
              platform: UpdatePlatform.ios,
            ),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );

        // Проходит когда все условия соблюдены
        final res = resolver.resolve(
          searchData: createTestSearchData(
            locale: UpdateLocale.ru,
            // Подходит
            sources: const [UpdateSource.googlePlay],
            version: '1.5.0',
            platform: UpdatePlatform.android,
          ),
          rules: rules,
        );
        expect(res.title, 'All Matchers Required');
      });
    });

    group('Граничные случаи и edge cases', () {
      test('Fuchsia платформа (менее распространенная)', () {
        final rules = [
          createTestRule(
            platforms: const [UpdatePlatform.fuchsia],
            title: 'Fuchsia Rule',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.fuchsia),
          rules: rules,
        );

        expect(res.title, 'Fuchsia Rule');
      });

      test('Множественные любые платформы в правиле', () {
        final rules = [
          createTestRule(
            platforms: const [
              UpdatePlatform.any,
              UpdatePlatform.any, // Дубликат any
              UpdatePlatform.android,
            ],
            title: 'Multiple Any',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.linux),
          rules: rules,
        );

        expect(res.title, 'Multiple Any');
      });

      test('Очень длинное имя кастомной платформы', () {
        const longNamePlatform = UpdatePlatform.custom(
          'very_very_very_long_custom_platform_name_for_edge_case_testing',
        );

        final rules = [
          createTestRule(
            platforms: [longNamePlatform],
            title: 'Long Name Platform',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(platform: longNamePlatform),
          rules: rules,
        );

        expect(res.title, 'Long Name Platform');
      });

      test('Регистр в именах кастомных платформ НЕ учитывается', () {
        const lowerCasePlatform = UpdatePlatform.custom('myplatform');
        const upperCasePlatform = UpdatePlatform.custom('MYPLATFORM');

        final rules = [
          createTestRule(
            platforms: [lowerCasePlatform],
            title: 'Case Insensitive',
          ),
        ];

        // Разный регистр - должно матчиться (регистр не учитывается)
        final res = resolver.resolve(
          searchData: createTestSearchData(platform: upperCasePlatform),
          rules: rules,
        );

        expect(res.title, 'Case Insensitive');
      });
    });

    group('Приоритеты платформенных правил в реальных сценариях', () {
      test('Каскад платформенных правил: общие → специфичные', () {
        final rules = [
          // Общее правило для всех
          createTestRule(
            title: 'Base Title',
            description: 'Base Description',
          ),
          // Правило для мобильных платформ
          createTestRule(
            platforms: const [UpdatePlatform.android, UpdatePlatform.ios],
            title: 'Mobile Title',
            // description остается базовый
          ),
          // Специфичное правило только для Android
          createTestRule(
            platforms: const [UpdatePlatform.android],
            description: 'Android Specific Description',
            // title остается мобильный
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.android),
          rules: rules,
        );

        expect(res.title, 'Mobile Title');
        expect(res.description, 'Android Specific Description');
      });

      test('Разные платформы получают разный контент', () {
        final rules = [
          createTestRule(
            platforms: const [UpdatePlatform.android],
            title: 'Android App Update',
            description: 'Update via Google Play',
          ),
          createTestRule(
            platforms: const [UpdatePlatform.ios],
            title: 'iOS App Update',
            description: 'Update via App Store',
          ),
          createTestRule(
            platforms: const [UpdatePlatform.windows],
            title: 'Windows App Update',
            description: 'Download from website',
          ),
        ];

        // Android
        final androidRes = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.android),
          rules: rules,
        );
        expect(androidRes.title, 'Android App Update');
        expect(androidRes.description, 'Update via Google Play');

        // iOS
        final iosRes = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.ios),
          rules: rules,
        );
        expect(iosRes.title, 'iOS App Update');
        expect(iosRes.description, 'Update via App Store');

        // Windows
        final windowsRes = resolver.resolve(
          searchData: createTestSearchData(platform: UpdatePlatform.windows),
          rules: rules,
        );
        expect(windowsRes.title, 'Windows App Update');
        expect(windowsRes.description, 'Download from website');
      });

      test('Платформенно-специфичная локализация', () {
        final rules = [
          // Общие правила для всех платформ
          createTestRule(
            title: 'Update Available',
            description: 'New version available',
          ),
          // Android на русском
          createTestRule(
            locales: [UpdateLocale.ru],
            platforms: const [UpdatePlatform.android],
            title: 'Доступно обновление Android',
          ),
          // iOS на русском
          createTestRule(
            locales: [UpdateLocale.ru],
            platforms: const [UpdatePlatform.ios],
            title: 'Доступно обновление iOS',
          ),
        ];

        // Android + Русский
        final androidRuRes = resolver.resolve(
          searchData: createTestSearchData(
            locale: UpdateLocale.ru,
            platform: UpdatePlatform.android,
          ),
          rules: rules,
        );
        expect(androidRuRes.title, 'Доступно обновление Android');

        // iOS + Русский
        final iosRuRes = resolver.resolve(
          searchData: createTestSearchData(
            locale: UpdateLocale.ru,
            platform: UpdatePlatform.ios,
          ),
          rules: rules,
        );
        expect(iosRuRes.title, 'Доступно обновление iOS');

        // Windows + Русский (только общее правило)
        final windowsRuRes = resolver.resolve(
          searchData: createTestSearchData(
            locale: UpdateLocale.ru,
            platform: UpdatePlatform.windows,
          ),
          rules: rules,
        );
        expect(windowsRuRes.title, 'Update Available'); // Общее правило
      });
    });
  });
}
