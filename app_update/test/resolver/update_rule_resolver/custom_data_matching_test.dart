import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/install_date_matcher.dart';
import 'helpers/resolver_test_helpers.dart';

// ignore_for_file: unnecessary_raw_strings

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
        createTestRule(title: 'ok', custom: const {'env_is': 'PROD'}),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {'env': 'prod'}),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test("rule 'any' как строка — всегда true", () {
      final rules = [
        createTestRule(title: 'ok', custom: const {'stage_is': 'ANY'}),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {'stage': 'qa'}),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test('NEW: Map в правиле игнорируется (не поддерживается)', () {
      final rules = [
        createTestRule(
          title: 'ok',
          custom: const {
            'meta_is': {
              'Flag': 'On', // Это Map - должно быть проигнорировано
            },
            'env_is': 'prod', // Примитив - должен работать
          },
        ),
      ];

      // Правило должно сработать, потому что поле meta_is (Map) игнорируется,
      // а env_is (примитив) проходит проверку
      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {
          'env': 'prod',
          // meta не нужно, так как meta_is игнорируется
        }),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test('list any-of: достаточно совпадения хотя бы одного элемента', () {
      final rules = [
        createTestRule(
          title: 'ok',
          custom: const {
            'tags_is': ['alpha', 'beta'],
          },
        ),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {
          'tags': ['gamma', 'BETA'],
        }),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test("list 'any' в правиле — всегда true", () {
      final rules = [
        createTestRule(
          title: 'ok',
          custom: const {
            'tags_is': ['any', 'test'],
          },
        ),
      ];

      final resEmptyList = resolver.resolve(
        searchData: createTestSearchData(custom: const {'tags': []}),
        rules: rules,
      );
      expect(resEmptyList.title, 'ok');

      final resEmpty = resolver.resolve(
        searchData: createTestSearchData(),
        rules: rules,
      );
      expect(resEmpty.title, 'ok');

      final resNull = resolver.resolve(
        searchData: createTestSearchData(custom: {
          'tags': null,
        }),
        rules: rules,
      );
      expect(resNull.title, 'ok');

      final resSome = resolver.resolve(
        searchData: createTestSearchData(custom: {
          'tags': [1, true, 'aba'],
        }),
        rules: rules,
      );

      expect(resSome.title, 'ok');
    });

    test('scalar vs list: совпадает если элемент найден в списке', () {
      final rules = [
        createTestRule(title: 'ok', custom: const {'tag_is': 'Alpha'}),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {
          'tag': ['alpha', 'beta'],
        }),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test('list vs scalar: достаточно совпадения одного элемента', () {
      final rules = [
        createTestRule(
          title: 'ok',
          custom: const {
            'tag_is': ['ALPHA', 'BETA'],
          },
        ),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {'tag': 'beta'}),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test('числа и булевы сравниваются по точному совпадению', () {
      List<UpdateRuleConfig<UpdateContentConfig>> rules = [
        createTestRule(title: 'ok', custom: const {'n_is': 5, 'b_is': true}),
      ];
      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {'n': 5, 'b': true}),
        rules: rules,
      );
      expect(res.title, 'ok');

      // Негативные
      rules = [
        createTestRule(title: 'bad', custom: const {'n_is': 5}),
      ];
      expect(
        () => resolver.resolve(
          searchData: createTestSearchData(custom: const {'n': '5'}),
          rules: rules,
        ),
        throwsA(isA<Exception>()),
      );

      rules = [
        createTestRule(title: 'bad', custom: const {'b_is': true}),
      ];
      expect(
        () => resolver.resolve(
          searchData: createTestSearchData(custom: const {'b': false}),
          rules: rules,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('list any-of: числа', () {
      final rules = [
        createTestRule(
          title: 'ok',
          custom: const {
            'nums_is': [5, 7],
          },
        ),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {
          'nums': [7],
        }),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test('negative: отсутствие ключа в поиске — false', () {
      final rules = [
        createTestRule(title: 'bad', custom: const {'env_is': 'prod'}),
      ];

      expect(
        () => resolver.resolve(
          searchData: createTestSearchData(custom: const {}),
          rules: rules,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('negative: список не содержит ни одного совпадения', () {
      final rules = [
        createTestRule(
          title: 'bad',
          custom: const {
            'tags_is': ['alpha'],
          },
        ),
      ];

      expect(
        () => resolver.resolve(
          searchData: createTestSearchData(custom: const {
            'tags': ['beta'],
          }),
          rules: rules,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('NEW: поля без суффикса "_is" блокируют правило', () {
      final rules = [
        createTestRule(
          title: 'bad',
          custom: const {
            'env_is': 'prod', // Проверяется
            'version': '1.0.0', // Неизвестное поле - блокирует
            'debug_mode': true, // Неизвестное поле - блокирует
          },
        ),
      ];

      expect(
        () => resolver.resolve(
          searchData: createTestSearchData(custom: const {
            'env': 'prod',
          }),
          rules: rules,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('NEW: List с Map игнорируется', () {
      final rules = [
        createTestRule(
          title: 'ok',
          custom: const {
            'items_is': [
              {'name': 'item1'}, // List<Map> - должен быть проигнорирован
              {'name': 'item2'},
            ],
            'tags_is': ['alpha', 'beta'], // List<String> - должен работать
          },
        ),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {
          'tags': ['beta'],
          // items не нужны, так как items_is игнорируется
        }),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test('NEW: смешанный List с Map и примитивами игнорируется', () {
      final rules = [
        createTestRule(
          title: 'ok',
          custom: const {
            'mixed_is': [
              'string',
              42,
              {'key': 'value'},
            ], // Смешанный - игнорируется
            'env_is': 'prod', // Примитив - работает
          },
        ),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {
          'env': 'prod',
        }),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test(
      'NEW: правило только с непримитивными полями игнорируется полностью',
      () {
        final rules = [
          createTestRule(
            title: 'ignored',
            custom: const {
              'config_is': {
                'debug': true,
                'level': 'info',
              }, // Map - игнорируется
              'items_is': [
                {'id': 1},
                {'id': 2},
              ], // List<Map> - игнорируется
            },
          ),
        ];

        // Правило должно сработать, потому что все поля игнорированы (filteredRuleCustom пустой)
        final res = resolver.resolve(
          searchData: createTestSearchData(custom: const {
            'any_field': 'any_value',
          }),
          rules: rules,
        );
        expect(res.title, 'ignored');
      },
    );

    test('NEW: null поддерживается, пустой список блокирует', () {
      List<UpdateRuleConfig<UpdateContentConfig>> rules = [
        createTestRule(
          title: 'ok',
          custom: const {
            'nullable_is': null, // null - поддерживается (всегда true)
            'env_is': 'prod',
          },
        ),
      ];

      final res = resolver.resolve(
        searchData: createTestSearchData(custom: const {
          'nullable':
              'any_value', // null в правиле должен матчить любое значение
          'env': 'prod',
        }),
        rules: rules,
      );
      expect(res.title, 'ok');

      // Negative case: пустой список в правиле блокирует любые значения
      rules = [
        createTestRule(
          title: 'bad',
          custom: const {
            'empty_list_is': <String>[], // Пустой список - никого не пускает
            'env_is': 'prod',
          },
        ),
      ];

      expect(
        () => resolver.resolve(
          searchData: createTestSearchData(custom: const {
            'empty_list': [
              'item1',
              'item2',
            ], // Не должно пройти из-за пустого списка в правиле
            'env': 'prod',
          }),
          rules: rules,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('NEW: кастомные матчеры потребляют свои поля', () {
      // Создаем resolver с InstallDateMatcher ПЕРЕД CustomDataMatcher
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

      final rules = [
        createTestRule(
          title: 'ok',
          custom: const {
            'min_delay_after_app_install_hours':
                24, // Поле для InstallDateMatcher
            'env_is': 'prod', // Поле для CustomDataMatcher
          },
        ),
      ];

      // InstallDateMatcher должен обработать и удалить свое поле,
      // затем CustomDataMatcher увидит только env_is и пропустит правило
      final currentDate = DateTime.now();
      final installDate =
          currentDate.subtract(const Duration(hours: 48)); // 48 часов назад

      final res = customResolver.resolve(
        searchData: createTestSearchData(
          target: UpdateViewTarget.any,
          locale: UpdateLocale.any,
          sources: [UpdateSource.any],
          appStatus: AppStatus.any,
          currentDate: currentDate,
          custom: {
            'app_install_date': installDate,
            'env': 'prod',
          },
        ),
        rules: rules,
      );
      expect(res.title, 'ok');
    });

    test('Логика сравнения списков - пересечение множеств', () {
      List<UpdateRuleConfig<UpdateContentConfig>> rules = [
        createTestRule(
          title: 'ok',
          custom: const {
            'tags_is': [
              'alpha',
              'gamma',
              'delta',
            ], // rule содержит alpha, gamma, delta
          },
        ),
      ];

      UpdateContentConfig res = resolver.resolve(
        searchData: createTestSearchData(custom: const {
          'tags': [
            'alpha',
            'beta',
          ], // search содержит alpha, beta - alpha пересекается
        }),
        rules: rules,
      );
      expect(
        res.title,
        'ok',
      ); // Проходит, потому что alpha есть в обоих списках

      // Negative case: нет пересечения между списками
      rules = [
        createTestRule(
          title: 'bad',
          custom: const {
            'tags_is': ['alpha', 'gamma'], // rule содержит только alpha, gamma
          },
        ),
      ];

      expect(
        () => resolver.resolve(
          searchData: createTestSearchData(custom: const {
            'tags': [
              'beta',
              'delta',
            ], // search содержит beta, delta - нет пересечения
          }),
          rules: rules,
        ),
        throwsA(isA<Exception>()),
      );

      // Edge case: один элемент пересекается из многих
      rules = [
        createTestRule(
          title: 'single_match',
          custom: const {
            'tags_is': ['alpha', 'gamma', 'epsilon'],
          },
        ),
      ];

      res = resolver.resolve(
        searchData: createTestSearchData(custom: const {
          'tags': ['beta', 'delta', 'gamma', 'zeta'], // gamma пересекается
        }),
        rules: rules,
      );
      expect(res.title, 'single_match'); // Достаточно одного пересечения
    });

    group('RegExp', () {
      test('Поддержка регулярных выражений', () {
        final rules = [
          createTestRule(
            title: 'valid_email',
            custom: const {
              'email_is':
                  r'regexp:^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$', // Email regex
            },
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(
            appStatus:
                AppStatus.active, // Добавляем appStatus для AppStatusMatcher
            custom: const {
              'email': 'user@example.com', // Валидный email
            },
          ),
          rules: rules,
        );
        expect(res.title, 'valid_email');
      });
      test('Невалидный email не проходит регулярку', () {
        // Negative case:
        final rules = [
          createTestRule(
            title: 'bad',
            custom: const {
              'email_is':
                  r'regexp:^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            },
          ),
        ];

        expect(
          () => resolver.resolve(
            searchData: createTestSearchData(
              appStatus: AppStatus.active,
              custom: const {
                'email': 'not-an-email', // Невалидный email
              },
            ),
            rules: rules,
          ),
          throwsA(isA<UpdateRuleResolverException>()),
        );
      });

      test('Невалидная регулярка бросает ошибку', () {
        final rules = [
          createTestRule(
            title: 'bad',
            custom: const {
              'email_is': r'regexp:]]', // Невалидная регулярка
            },
          ),
        ];

        expect(
          () => resolver.resolve(
            searchData: createTestSearchData(
              appStatus: AppStatus.active,
              custom: const {
                'email': 'email@example.com',
              },
            ),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('Смешивание обычных значений и регулярок в списке', () {
        final rules = [
          createTestRule(
            title: 'mixed',
            custom: const {
              'user_type_is': [
                'admin',
                r'regexp:^premium_.*',
              ], // Обычное + регулярка
            },
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(
            appStatus: AppStatus.active,
            custom: const {
              'user_type': 'premium_gold', // Попадает под регулярку
            },
          ),
          rules: rules,
        );
        expect(res.title, 'mixed');

        // Проверка обычного значения из того же списка
        final res2 = resolver.resolve(
          searchData: createTestSearchData(
            appStatus: AppStatus.active,
            custom: const {
              'user_type': 'admin', // Обычное значение
            },
          ),
          rules: rules,
        );

        expect(res2.title, 'mixed');
      });
    });
  });
}
