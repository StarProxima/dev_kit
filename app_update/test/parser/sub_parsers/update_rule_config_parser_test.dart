//skip:file: cast_nullable_to_non_nullable, avoid-type-casts

import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/parser_test_helpers.dart';

class _MergeableMapAdapter implements Mergeable<_MergeableMapAdapter> {
  final Map<String, dynamic> map;

  const _MergeableMapAdapter(this.map);

  @override
  _MergeableMapAdapter merge(covariant _MergeableMapAdapter other) {
    return _MergeableMapAdapter({...map, ...other.map});
  }
}

void main() {
  group('UpdateRuleConfigParser', () {
    const parser = UpdateRuleConfigParser();

    test('Базовое правило с data', () {
      const yamlStr = '''
        when:
          app_status_is: outdated
        data:
          title: "Заголовок"
      ''';
      final map = parseYamlToMap(yamlStr);
      final result = parser.parse<_MergeableMapAdapter>(
        map,
        dataParser: (v) => _MergeableMapAdapter(
          Map<String, dynamic>.of(v! as Map<String, dynamic>),
        ),
        isDebug: true,
      );
      expect(result, isA<UpdateRuleConfig<_MergeableMapAdapter>>());
      expect(result?.when?.appStatusIs?.firstOrNull?.name, 'outdated');
      expect(result?.data.map['title'], 'Заголовок');
    });

    test('Массивы значений', () {
      const yamlStr = '''
        when:
          app_status_is: [outdated, active]
          locale_is: [ru, en]
          view_target_is: [card, dialog]
          app_version_is: [">=1.0.0", "<2.0.0"]
          source_is: [googlePlay, appStore]
        data:
          title: test
      ''';
      final map = parseYamlToMap(yamlStr);
      final result = parser.parse<_MergeableMapAdapter>(
        map,
        dataParser: (v) => _MergeableMapAdapter(
          Map<String, dynamic>.of(v! as Map<String, dynamic>),
        ),
        isDebug: true,
      );
      expect(result?.when?.appStatusIs?.length, 2);
      expect(result?.when?.localeIs?.length, 2);
      expect(result?.when?.viewTargetIs?.length, 2);
      expect(result?.when?.appVersionIs?.length, 2);
      expect(result?.when?.sourceIs?.length, 2);
    });

    test('null возвращает null', () {
      final result = parser.parse<_MergeableMapAdapter>(
        null,
        dataParser: (v) => _MergeableMapAdapter(
          Map<String, dynamic>.of(v! as Map<String, dynamic>),
        ),
        isDebug: true,
      );
      expect(result, isNull);
    });

    test('Ошибка при неверном типе', () {
      expect(
        () => parser.parse<_MergeableMapAdapter>(
          123,
          dataParser: (v) => _MergeableMapAdapter(
            Map<String, dynamic>.of(v! as Map<String, dynamic>),
          ),
          isDebug: true,
        ),
        throwsA(isA<ParseConfigException>()),
      );
      expect(
        () => parser.parse<_MergeableMapAdapter>(
          [],
          dataParser: (v) => _MergeableMapAdapter(
            Map<String, dynamic>.of(v! as Map<String, dynamic>),
          ),
          isDebug: true,
        ),
        throwsA(isA<ParseConfigException>()),
      );
    });

    test('customParams содержит неиспользованные поля', () {
      const yamlStr = '''
        when:
          app_status_is: outdated
          custom_params:
            custom_field: 42
        data:
          title: test
      ''';
      final map = parseYamlToMap(yamlStr);
      final result = parser.parse<_MergeableMapAdapter>(
        map,
        dataParser: (v) => _MergeableMapAdapter(
          Map<String, dynamic>.of(v! as Map<String, dynamic>),
        ),
        isDebug: true,
      );
      expect(result?.when?.customParams, containsPair('custom_field', 42));
    });

    test('Парсит delay_hours, gradual_rollout_hours, user_segmentation_percent',
        () {
      const yamlStr = '''
        when:
          app_status_is: deprecated
        rollout:
          delay_hours: 12
          gradual_rollout_hours: 72
          user_segmentation_percent: 12.5
        data:
          title: test
      ''';
      final map = parseYamlToMap(yamlStr);
      final result = parser.parse<_MergeableMapAdapter>(
        map,
        dataParser: (v) => _MergeableMapAdapter(
          Map<String, dynamic>.of(v! as Map<String, dynamic>),
        ),
        isDebug: true,
      );
      expect(result, isA<UpdateRuleConfig<_MergeableMapAdapter>>());
      expect(result?.rollout?.delay?.inHours, 12);
      expect(result?.rollout?.gradualRolloutDuration?.inHours, 72);
      expect(result?.rollout?.userSegmentationPercent, closeTo(12.5, 0.0001));
    });
  });
}
