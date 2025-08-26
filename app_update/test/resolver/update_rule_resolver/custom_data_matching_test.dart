import 'package:app_update/src/resolver/update_rule_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/resolver_test_helpers.dart';

void main() {
  group('UpdateRuleResolver - CustomData matching', () {
    const resolver = UpdateRuleResolver();

    test('Пустое правило или null в правиле — всегда true', () {
      final rules = [
        createTestRule(title: 'ok'),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test('rule map vs search map: кейсы ключей/значений игнорируются', () {
      final rules = [
        createTestRule(custom: const {'env_is': 'PROD'}, title: 'ok'),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {'env': 'prod'}),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test("rule 'any' как строка — всегда true", () {
      final rules = [
        createTestRule(custom: const {'stage_is': 'ANY'}, title: 'ok'),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {'stage': 'qa'}),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test('nested map: глубокое сравнение', () {
      final rules = [
        createTestRule(custom: const {
          'meta_is': {
            'Flag': 'On',
          }
        }, title: 'ok'),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {
          'meta': {
            'fLaG': 'on',
          }
        }),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test('list any-of: достаточно совпадения хотя бы одного элемента', () {
      final rules = [
        createTestRule(custom: const {
          'tags_is': ['alpha', 'beta']
        }, title: 'ok'),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {
          'tags': ['gamma', 'BETA']
        }),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test("list 'any' в правиле — всегда true", () {
      final rules = [
        createTestRule(custom: const {
          'tags_is': ['any']
        }, title: 'ok'),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {'tags': []}),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test('scalar vs list: совпадает если элемент найден в списке', () {
      final rules = [
        createTestRule(custom: const {'tag_is': 'Alpha'}, title: 'ok'),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {
          'tag': ['alpha', 'beta']
        }),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test('list vs scalar: достаточно совпадения одного элемента', () {
      final rules = [
        createTestRule(custom: const {
          'tag_is': ['ALPHA', 'BETA']
        }, title: 'ok'),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {'tag': 'beta'}),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test('числа и булевы сравниваются по точному совпадению', () {
      // Позитивные
      var rules = [
        createTestRule(custom: const {'n_is': 5, 'b_is': true}, title: 'ok'),
      ];
      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {'n': 5, 'b': true}),
        rules: rules,
      );
      expect(res.title, 'ok');

      // Негативные
      rules = [
        createTestRule(custom: const {'n_is': 5}, title: 'bad'),
      ];
      expect(
        () => resolver.resolve(
            searchData: createTestSearchData(custom: const {'n': '5'}),
            rules: rules),
        throwsA(isA<Exception>()),
      );

      rules = [
        createTestRule(custom: const {'b_is': true}, title: 'bad'),
      ];
      expect(
        () => resolver.resolve(
            searchData: createTestSearchData(custom: const {'b': false}),
            rules: rules),
        throwsA(isA<Exception>()),
      );
    });

    test('list any-of: числа', () {
      final rules = [
        createTestRule(custom: const {
          'nums_is': [5, 7]
        }, title: 'ok'),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {
          'nums': [7]
        }),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test('negative: отсутствие ключа в поиске — false', () {
      final rules = [
        createTestRule(custom: const {'env_is': 'prod'}, title: 'bad'),
      ];

      expect(
        () => resolver.resolve(
            searchData: createTestSearchData(custom: const {}), rules: rules),
        throwsA(isA<Exception>()),
      );
    });

    test('negative: список не содержит ни одного совпадения', () {
      final rules = [
        createTestRule(custom: const {
          'tags_is': ['alpha']
        }, title: 'bad'),
      ];

      expect(
        () => resolver.resolve(
            searchData: createTestSearchData(custom: const {
              'tags': ['beta']
            }),
            rules: rules),
        throwsA(isA<Exception>()),
      );
    });

    test('NEW: поля без суффикса "_is" игнорируются', () {
      final rules = [
        createTestRule(custom: const {
          'env_is': 'prod', // Проверяется
          'version': '1.0.0', // Игнорируется
          'debug_mode': true, // Игнорируется
        }, title: 'ok'),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {
          'env': 'prod',
          // version и debug_mode не нужны, так как они игнорируются
        }),
        rules: rules,
      );
      expect(res.title, 'ok');
    });
  });
}
