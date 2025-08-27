import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_update/app_update.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';
import 'package:app_update/app_update.dart';

import '../helpers/install_date_matcher.dart';
import '../helpers/resolver_test_helpers.dart';

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
          custom: const {'min_delay_after_app_install_hours': 7 * 24}, // 7 дней
          title: 'Показать пользователю через неделю после установки',
        ),
      ];

      final res = customResolver.resolve(
        searchData: createTestSearchData(
          appInstallDate: installDate,
          currentDate: currentDate,
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
          custom: const {'min_delay_after_app_install_hours': 7 * 24}, // 7 дней
          title: 'bad',
        ),
      ];

      expect(
        () => customResolver.resolve(
          searchData: createTestSearchData(
            appInstallDate: installDate,
            currentDate: currentDate,
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
          custom: const {'min_delay_after_app_install_hours': 24},
          title: 'bad',
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
          InstallDateMatcher(), // ПЕРЕД CustomDataMatcher
          CustomDataMatcher(),
        ],
      );

      final installDate = DateTime(2024, 10, 1, 12);
      final currentDate = DateTime(2024, 10, 8, 12); // 7 дней спустя

      final rules = [
        createTestRule(
          custom: const {
            'min_delay_after_app_install_hours': 5 * 24, // 5 дней
            'env_is': 'prod', // Для CustomDataMatcher
          },
          title: 'Combined matchers work',
        ),
      ];

      final res = customResolver.resolve(
        searchData: createTestSearchData(
          appInstallDate: installDate,
          currentDate: currentDate,
          custom: const {'env': 'prod'}, // Для CustomDataMatcher
        ),
        rules: rules,
      );
      expect(res.title, 'Combined matchers work');
    });
  });
}
