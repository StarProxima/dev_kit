part of '../parser_test.dart';

class MergeableMapAdapter implements Mergeable {
  final Map<String, dynamic> map;

  MergeableMapAdapter(this.map);

  @override
  MergeableMapAdapter merge(covariant MergeableMapAdapter other) {
    return MergeableMapAdapter({...map, ...other.map});
  }
}

void runUpdateRuleConfigParserTests() {
  group('UpdateRuleConfigParser', () {
    const parser = UpdateRuleConfigParser();

    test('Базовое правило с data', () {
      const yamlStr = '''
        app_status_is: outdated
        data:
          title: "Заголовок"
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse<MergeableMapAdapter>(map,
          dataParser: (v) => MergeableMapAdapter(Map<String, dynamic>.from(v)));
      expect(result, isA<UpdateRuleConfig<MergeableMapAdapter>>());
      expect(result?.appStatusIs?.first.name, 'outdated');
      expect(result?.data.map['title'], 'Заголовок');
    });

    test('Массивы значений', () {
      const yamlStr = '''
        app_status_is: [outdated, active]
        locale_is: [ru, en]
        view_target_is: [card, dialog]
        version_is: [">=1.0.0", "<2.0.0"]
        source_is: [googlePlay, appStore]
        data:
          title: test
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse<MergeableMapAdapter>(map,
          dataParser: (v) => MergeableMapAdapter(Map<String, dynamic>.from(v)));
      expect(result?.appStatusIs?.length, 2);
      expect(result?.localeIs?.length, 2);
      expect(result?.viewTargetIs?.length, 2);
      expect(result?.versionIs?.length, 2);
      expect(result?.sourceIs?.length, 2);
    });

    test('null возвращает null', () {
      final result = parser.parse<MergeableMapAdapter>(null,
          dataParser: (v) => MergeableMapAdapter(Map<String, dynamic>.from(v)));
      expect(result, isNull);
    });

    test('Ошибка при неверном типе', () {
      expect(
          () => parser.parse<MergeableMapAdapter>(123,
              dataParser: (v) =>
                  MergeableMapAdapter(Map<String, dynamic>.from(v))),
          throwsA(isA<UpdateConfigException>()));
      expect(
          () => parser.parse<MergeableMapAdapter>([],
              dataParser: (v) =>
                  MergeableMapAdapter(Map<String, dynamic>.from(v))),
          throwsA(isA<UpdateConfigException>()));
    });

    test('customData содержит неиспользованные поля', () {
      const yamlStr = '''
        app_status_is: outdated
        custom_field: 42
        data:
          title: test
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse<MergeableMapAdapter>(map,
          dataParser: (v) => MergeableMapAdapter(Map<String, dynamic>.from(v)));
      expect(result?.customData, containsPair('custom_field', 42));
    });

    test('Парсит delay_hours, rollout_hours, segmentation_percent', () {
      const yamlStr = '''
        app_status_is: deprecated
        delay_hours: 12
        rollout_hours: 72
        segmentation_percent: 12.5
        data:
          title: test
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse<MergeableMapAdapter>(map,
          dataParser: (v) => MergeableMapAdapter(Map<String, dynamic>.from(v)));
      expect(result, isA<UpdateRuleConfig<MergeableMapAdapter>>());
      expect(result?.delay?.inHours, 12);
      expect(result?.rollout?.inHours, 72);
      expect(result?.segmentationPercent, closeTo(12.5, 0.0001));
    });
  });
}
