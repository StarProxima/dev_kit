#!/usr/bin/env dart
// ignore_for_file: avoid_print, unnecessary_raw_strings

import 'dart:io';

/// Скрипт для генерации экспорт файла app_update.dart
void main() async {
  print('Генерация файла экспортов...');

  final srcDir = Directory('lib/src');
  final libFile = File('lib/app_update.dart');

  if (!srcDir.existsSync()) {
    print('Ошибка: Директория lib/src не найдена');
    exit(1);
  }

  /// Получаем все .dart файлы из src рекурсивно
  final dartFiles = await _getAllDartFiles(srcDir);

  /// Сортируем для стабильного порядка
  dartFiles.sort();

  /// Генерируем содержимое файла
  final content = _generateExportContent(dartFiles);

  /// Записываем в файл
  await libFile.writeAsString(content);

  print('✅ Файл app_update.dart обновлен!');
  print('📁 Найдено ${dartFiles.length} файлов:');
  for (final file in dartFiles) {
    print('  - $file');
  }
}

/// Рекурсивно получает все .dart файлы из директории
Future<List<String>> _getAllDartFiles(Directory dir) async {
  final files = <String>[];

  await for (final entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      /// Преобразуем абсолютный путь в относительный от lib/
      final relativePath = entity.path
          .replaceFirst(RegExp(r'.*lib/'), '')
          .replaceAll(Platform.pathSeparator, '/');

      files.add(relativePath);
    }
  }

  return files;
}

/// Генерирует содержимое экспорт файла
String _generateExportContent(List<String> dartFiles) {
  final buffer = StringBuffer();

  /// Заголовок
  buffer.writeln('/// Library for App Update.');
  buffer.writeln('library app_update;');
  buffer.writeln();

  /// Export statements
  for (final file in dartFiles) {
    buffer.writeln("export '$file';");
  }

  return buffer.toString();
}
