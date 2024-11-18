// ignore_for_file: avoid-long-functions, prefer-moving-to-variable, avoid-long-files

import 'dart:ui';

import 'package:app_update/src/parser/models/update_config_exception.dart';
import 'package:app_update/src/parser/update_config_parser.dart';
import 'package:app_update/src/shared/update_alert_type.dart';
import 'package:app_update/src/shared/version_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateTextContainerParser', () {
    const parser = UpdateTextContainerParser();
    const isDebug = true;

    test('parses text_0 with only title at the root level', () {
      final value = {
        'title': 'Title',
      };

      final result = parser.parse(value, isDebug: isDebug);

      expect(result, isNotNull);

      final config = result?.getByBase(
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.base,
        locale: const Locale('base'),
      );

      expect(config?.title, 'Title');
    });

    test('parses text_1 with locales as keys', () {
      final value = {
        'ru': {
          'title': 'Заголовок',
        },
        'en': {
          'title': 'Title',
        },
      };

      final result = parser.parse(value, isDebug: isDebug);

      expect(result, isNotNull);

      final configRu = result?.getByBase(
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.base,
        locale: const Locale('ru'),
      );
      final configEn = result?.getByBase(
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.base,
        locale: const Locale('en'),
      );

      expect(configRu?.title, 'Заголовок');
      expect(configEn?.title, 'Title');
    });

    test('parses text_2 with version statuses and locales', () {
      final value = {
        'base': {
          'ru': {
            'title': 'Базовый заголовок',
          },
          'en': {
            'title': 'Base Title',
          },
        },
        'unsupported': {
          'ru': {
            'title': 'Заголовок для неподдерживаемых версий',
          },
        },
      };

      final result = parser.parse(value, isDebug: isDebug);

      expect(result, isNotNull);

      // Base version status
      final baseConfigRu = result?.getByBase(
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.base,
        locale: const Locale('ru'),
      );
      final baseConfigEn = result?.getByBase(
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.base,
        locale: const Locale('en'),
      );

      // Unsupported version status
      final unsupportedConfigRu = result?.getByBase(
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.unsupported,
        locale: const Locale('ru'),
      );

      expect(baseConfigRu?.title, 'Базовый заголовок');
      expect(baseConfigEn?.title, 'Base Title');
      expect(unsupportedConfigRu?.title, 'Заголовок для неподдерживаемых версий');
    });

    test('parses text_3 with alert types, version statuses, and locales', () {
      final value = {
        'base': {
          'base': {
            'ru': {
              'title': 'Базовый заголовок',
            },
            'en': {
              'title': 'Base Title',
            },
          },
          'unsupported': {
            'ru': {
              'title': 'Заголовок для неподдерживаемых версий',
            },
          },
        },
        'card': {
          'title': 'Карточный заголовок',
        },
      };

      final result = parser.parse(value, isDebug: isDebug);

      expect(result, isNotNull);

      // Base alert type and version status
      final baseConfigRu = result?.getByBase(
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.base,
        locale: const Locale('ru'),
      );
      final baseConfigEn = result?.getByBase(
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.base,
        locale: const Locale('en'),
      );

      // Unsupported version status
      final unsupportedConfigRu = result?.getByBase(
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.unsupported,
        locale: const Locale('ru'),
      );

      // Card alert type
      final cardConfig = result?.getByBase(
        type: UpdateAlertTypeBase.card,
        status: VersionStatusBase.base,
        locale: const Locale('base'),
      );

      expect(baseConfigRu?.title, 'Базовый заголовок');
      expect(baseConfigEn?.title, 'Base Title');
      expect(unsupportedConfigRu?.title, 'Заголовок для неподдерживаемых версий');
      expect(cardConfig?.title, 'Карточный заголовок');
    });

    test('parses text_999 with complex nesting and missing keys', () {
      final value = {
        'ru': {
          'unsupported': {
            'dialog': {
              'title': 'Заголовок RU Unsupported Dialog',
            },
          },
        },
        'en': {
          'dialog': {
            'unsupported': {
              'title': 'Title EN Unsupported Dialog',
            },
          },
        },
        'fr': {
          'dialog': {
            'title': 'Titre FR Dialog',
          },
        },
        'es': {
          'unsupported': {
            'title': 'Título ES Unsupported',
          },
        },
        'ch': {
          'title': '标题 CH',
        },
      };

      final result = parser.parse(value, isDebug: isDebug);

      expect(result, isNotNull);

      // ru locale
      final ruUnsupportedDialogConfig = result?.getByBase(
        type: UpdateAlertTypeBase.dialog,
        status: VersionStatusBase.unsupported,
        locale: const Locale('ru'),
      );

      // en locale
      final enUnsupportedDialogConfig = result?.getByBase(
        type: UpdateAlertTypeBase.dialog,
        status: VersionStatusBase.unsupported,
        locale: const Locale('en'),
      );

      // fr locale
      final frDialogConfig = result?.getByBase(
        type: UpdateAlertTypeBase.dialog,
        status: VersionStatusBase.base,
        locale: const Locale('fr'),
      );

      // es locale
      final esUnsupportedConfig = result?.getByBase(
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.unsupported,
        locale: const Locale('es'),
      );

      // ch locale
      final chBaseConfig = result?.getByBase(
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.base,
        locale: const Locale('ch'),
      );

      expect(ruUnsupportedDialogConfig?.title, 'Заголовок RU Unsupported Dialog');
      expect(enUnsupportedDialogConfig?.title, 'Title EN Unsupported Dialog');
      expect(frDialogConfig?.title, 'Titre FR Dialog');
      expect(esUnsupportedConfig?.title, 'Título ES Unsupported');
      expect(chBaseConfig?.title, '标题 CH');
    });

    test('returns null when input is null or empty', () {
      final resultNull = parser.parse(null, isDebug: isDebug);
      final resultEmpty = parser.parse({}, isDebug: isDebug);

      expect(resultNull, isNull);
      expect(resultEmpty, isNull);
    });

    test('throws exception when input is not a Map', () {
      expect(
        () => parser.parse('invalid_input', isDebug: isDebug),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('parses text with missing optional fields', () {
      final value = {
        'base': {
          'en': {
            'title': 'Title',
          },
        },
      };

      final result = parser.parse(value, isDebug: isDebug);

      expect(result, isNotNull);

      final config = result?.getByBase(
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.base,
        locale: const Locale('en'),
      );

      expect(config?.title, 'Title');
      expect(config?.description, isNull);
    });

    test('handles multiple locales and missing keys gracefully', () {
      final value = {
        'dialog': {
          'updatable': {
            'ru': {
              'title': 'Обновление доступно',
            },
            'en': {
              'description': 'Update is available',
            },
          },
        },
      };

      final result = parser.parse(value, isDebug: isDebug);

      expect(result, isNotNull);

      final ruConfig = result?.getByBase(
        type: UpdateAlertTypeBase.dialog,
        status: VersionStatusBase.updatable,
        locale: const Locale('ru'),
      );
      final enConfig = result?.getByBase(
        type: UpdateAlertTypeBase.dialog,
        status: VersionStatusBase.updatable,
        locale: const Locale('en'),
      );

      expect(ruConfig?.title, 'Обновление доступно');
      expect(ruConfig?.description, isNull);

      expect(enConfig?.title, isNull);
      expect(enConfig?.description, 'Update is available');
    });

    test('parses nested structures with base keys', () {
      final value = {
        'base': {
          'base': {
            'en': {
              'title': 'Base Title',
            },
          },
        },
        'dialog': {
          'unsupported': {
            'base': {
              'title': 'Unsupported Dialog Title',
            },
          },
        },
      };

      final result = parser.parse(value, isDebug: isDebug);

      expect(result, isNotNull);

      final baseConfigEn = result?.getByBase(
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.base,
        locale: const Locale('en'),
      );

      final unsupportedDialogConfig = result?.getByBase(
        type: UpdateAlertTypeBase.dialog,
        status: VersionStatusBase.unsupported,
        locale: const Locale('base'),
      );

      expect(baseConfigEn?.title, 'Base Title');
      expect(unsupportedDialogConfig?.title, 'Unsupported Dialog Title');
    });

    test('parses when alert type is missing (defaults to base)', () {
      final value = {
        'unsupported': {
          'en': {
            'title': 'Title for unsupported versions',
          },
        },
      };

      final result = parser.parse(value, isDebug: isDebug);

      expect(result, isNotNull);

      final config = result?.getByBase(
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.unsupported,
        locale: const Locale('en'),
      );

      expect(config?.title, 'Title for unsupported versions');
    });

    test('parses when version status is missing (defaults to base)', () {
      final value = {
        'dialog': {
          'en': {
            'title': 'Dialog Title',
          },
        },
      };

      final result = parser.parse(value, isDebug: isDebug);

      expect(result, isNotNull);

      final config = result?.getByBase(
        type: UpdateAlertTypeBase.dialog,
        status: VersionStatusBase.base,
        locale: const Locale('en'),
      );

      expect(config?.title, 'Dialog Title');
    });

    test('parses when locale is missing (defaults to base)', () {
      final value = {
        'dialog': {
          'unsupported': {
            'title': 'Title without locale',
          },
        },
      };

      final result = parser.parse(value, isDebug: isDebug);

      expect(result, isNotNull);

      final config = result?.getByBase(
        type: UpdateAlertTypeBase.dialog,
        status: VersionStatusBase.unsupported,
        locale: const Locale('base'),
      );

      expect(config?.title, 'Title without locale');
    });

    test('parses complex nested structures with custom data', () {
      final value = {
        'dialog': {
          'unsupported': {
            'en': {
              'title': 'Unsupported Dialog Title',
              'custom_field': 'Custom Value',
            },
          },
        },
      };

      final result = parser.parse(value, isDebug: isDebug);

      expect(result, isNotNull);

      final config = result?.getByBase(
        type: UpdateAlertTypeBase.dialog,
        status: VersionStatusBase.unsupported,
        locale: const Locale('en'),
      );

      expect(config?.title, 'Unsupported Dialog Title');
      expect(config?.customData?['custom_field'], 'Custom Value');
    });

    test('ignores unrecognized keys and continues parsing', () {
      final value = {
        'lc': {
          'unknown_status': {
            'unknown_type': {
              'title': 'Title',
            },
          },
        },
        'en': {
          'title': 'Valid Title',
        },
      };

      final result = parser.parse(value, isDebug: isDebug);

      expect(result, isNotNull);

      final config = result?.getByBase(
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.base,
        locale: const Locale('en'),
      );

      expect(config?.title, 'Valid Title');
    });

    test('throws exception when value inside map is not a Map', () {
      final value = {
        'dialog': {
          'unsupported': 'Invalid Value',
        },
      };

      final result = parser.parse(value, isDebug: isDebug);

      expect(
        result?.value.isEmpty,
        true,
      );
    });
  });
}
