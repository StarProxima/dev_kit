import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/install_date_matcher.dart';
import 'helpers/resolver_test_helpers.dart';

void main() {
  group('InstallDateMatcher integration tests', () {
    test('InstallDateMatcher: проверка времени после установки приложения', () {
      // Создаем резолвер только с InstallDateMatcher для демонстрации
      const customResolver = UpdateRuleResolver(
        matchers: [InstallDateMatcher()],
      );

      final installDate = DateTime(2024, 10, 1, 12);
      final currentDate = DateTime(2024, 10, 15, 12); // 14 дней спустя

      final rules = [
        createTestRule(
          // 7 дней
          title: 'Показать пользователю через неделю после установки',
          custom: const {'min_delay_after_app_install_hours': 7 * 24},
        ),
      ];

      final res = customResolver.resolve(
        searchData: createTestSearchData(
          currentDate: currentDate,
          customAppInstallDate: installDate,
        ),
        rules: rules,
      );
      expect(res.title, 'Показать пользователю через неделю после установки');
    });

    test('InstallDateMatcher: слишком рано после установки', () {
      const customResolver = UpdateRuleResolver(
        matchers: [InstallDateMatcher()],
      );

      final installDate = DateTime(2024, 10, 1, 12);
      final currentDate = DateTime(2024, 10, 3, 12); // 2 дня спустя

      final rules = [
        createTestRule(
          // 7 дней
          title: 'bad',
          custom: const {'min_delay_after_app_install_hours': 7 * 24},
        ),
      ];

      expect(
        () => customResolver.resolve(
          searchData: createTestSearchData(
            currentDate: currentDate,
            customAppInstallDate: installDate,
          ),
          rules: rules,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('InstallDateMatcher: блокировка без даты установки', () {
      const customResolver = UpdateRuleResolver(
        matchers: [InstallDateMatcher()],
      );

      final rules = [
        createTestRule(
          title: 'bad',
          custom: const {'min_delay_after_app_install_hours': 24},
        ),
      ];

      expect(
        () => customResolver.resolve(
          searchData: createTestSearchData(), // appInstallDate == null
          rules: rules,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('InstallDateMatcher: интеграция с другими матчерами', () {
      // Тестируем InstallDateMatcher в комбинации с другими
      const customResolver = UpdateRuleResolver(
        matchers: [
          ViewTargetMatcher(),
          LocaleMatcher(),
          SourceMatcher(),
          VersionMatcher(),
          AppStatusMatcher(),
          TemporalMatcher(),
          InstallDateMatcher(), // ПЕРЕД customParamsMatcher
          CustomParamsMatcher(),
        ],
      );

      final installDate = DateTime(2024, 10, 1, 12);
      final currentDate = DateTime(2024, 10, 8, 12); // 7 дней спустя

      final rules = [
        createTestRule(
          title: 'Combined matchers work',
          custom: const {
            'min_delay_after_app_install_hours': 5 * 24, // 5 дней
            'env_is': 'prod', // Для customParamsMatcher
          },
        ),
      ];

      final res = customResolver.resolve(
        searchData: createTestSearchData(
          currentDate: currentDate,
          customAppInstallDate: installDate,
          custom: const {'env': 'prod'}, // Для customParamsMatcher
        ),
        rules: rules,
      );
      expect(res.title, 'Combined matchers work');
    });
  });
}
