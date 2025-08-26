import 'package:app_update/src/parser/common.dart';
import 'package:app_update/src/parser/sub_parsers/update_rule_config_parser.dart';
import 'package:app_update/src/shared/models/mergeable.dart';
import 'package:app_update/src/shared/models/update_rule/update_rule_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

class MergeableMapAdapter implements Mergeable {
  final Map<String, dynamic> map;

  MergeableMapAdapter(this.map);

  @override
  MergeableMapAdapter merge(covariant MergeableMapAdapter other) {
    return MergeableMapAdapter({...map, ...other.map});
  }
}

void main() {
  group('UpdateRuleConfigParser', () {
    const parser = UpdateRuleConfigParser();

    test('Базовое правило с data', () {
      const yamlStr = '''
        app_statuses: outdated
        data:
          title: "Заголовок"
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse<MergeableMapAdapter>(map,
          dataParser: (v) => MergeableMapAdapter(Map<String, dynamic>.from(v)));
      expect(result, isA<UpdateRuleConfig<MergeableMapAdapter>>());
      expect(result?.appStatuses?.first.name, 'outdated');
      expect(result?.data.map['title'], 'Заголовок');
    });

    test('Массивы значений', () {
      const yamlStr = '''
        app_statuses: [outdated, active]
        locales: [ru, en]
        view_targets: [card, dialog]
        versions: [">=1.0.0", "<2.0.0"]
        sources: [googlePlay, appStore]
        data:
          title: test
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse<MergeableMapAdapter>(map,
          dataParser: (v) => MergeableMapAdapter(Map<String, dynamic>.from(v)));
      expect(result?.appStatuses?.length, 2);
      expect(result?.locales?.length, 2);
      expect(result?.viewTargets?.length, 2);
      expect(result?.versions?.length, 2);
      expect(result?.sources?.length, 2);
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
        app_statuses: outdated
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
        app_statuses: deprecated
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
