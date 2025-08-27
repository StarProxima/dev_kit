import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('UpdateContentConfigParser', () {
    const parser = UpdateContentConfigParser();

    test('Парсинг полного набора полей', () {
      const yamlStr = '''
        update_url: https://example.com
        title: "Заголовок"
        description: "Описание"
        release_notes_title: "Заметки"
        release_notes: "Текст заметок"
        skip_button: "Пропустить"
        postpone_button: "Позже"
        update_button: "Обновить"
        custom_field: 123
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse(map);
      expect(result, isA<UpdateContentConfig>());
      expect(result?.updateUrl, Uri.parse('https://example.com'));
      expect(result?.title, 'Заголовок');
      expect(result?.description, 'Описание');
      expect(result?.releaseNotesTitle, 'Заметки');
      expect(result?.releaseNotes, 'Текст заметок');
      expect(result?.skipButton, 'Пропустить');
      expect(result?.postponeButton, 'Позже');
      expect(result?.updateButton, 'Обновить');
      expect(result?.customData, containsPair('custom_field', 123));
    });

    test('Парсинг с частичным набором полей', () {
      const yamlStr = '''
        title: "Заголовок"
        custom_field: true
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse(map);
      expect(result, isA<UpdateContentConfig>());
      expect(result?.title, 'Заголовок');
      expect(result?.description, isNull);
      expect(result?.customData, containsPair('custom_field', true));
    });

    test('Парсинг null возвращает null', () {
      final result = parser.parse(null);
      expect(result, isNull);
    });

    test('Ошибка при неверном типе входных данных', () {
      expect(
        () => parser.parse('not a map'),
        throwsA(isA<ParseConfigException>()),
      );
      expect(() => parser.parse(123), throwsA(isA<ParseConfigException>()));
      expect(() => parser.parse([]), throwsA(isA<ParseConfigException>()));
    });

    test('Ошибка при нестроковых значениях полей', () {
      final map = {
        'title': 123,
      };
      expect(() => parser.parse(map), throwsA(isA<ParseConfigException>()));
    });
  });
}
