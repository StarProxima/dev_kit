#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';

/// Скрипт для рефакторинга структуры тестов:
/// - удаляет part/part of и заменяет их импортами
/// - переименовывает *_group.dart в *_test.dart
/// - заменяет run**Tests() на main()
void main(List<String> args) async {
  String targetDir = 'test';
  bool dryRun = false;

  for (final arg in args) {
    if (arg == '--dry-run') {
      dryRun = true;
    } else if (!arg.startsWith('--')) {
      targetDir = arg;
    }
  }

  if (args.contains('--help')) {
    print(
        'Использование: dart run tools/refactor_tests.dart [директория] [--dry-run]');
    print('  директория: путь к тестам (по умолчанию: test)');
    print('  --dry-run: показать изменения без их выполнения');
    return;
  }

  final testDir = Directory(targetDir);

  if (!testDir.existsSync()) {
    print('❌ Ошибка: Директория $targetDir не найдена');
    exit(1);
  }

  if (dryRun) {
    print('🔍 DRY RUN: Анализ структуры тестов в директории: $targetDir');
  } else {
    print('🔧 Рефакторинг структуры тестов в директории: $targetDir');
  }

  /// Этап 1: Найти все файлы с part/part of
  final allDartFiles = await _getAllDartFiles(testDir);
  final mainTestFiles = <File>[];
  final partOfFiles = <File>[];

  for (final file in allDartFiles) {
    final content = await file.readAsString();

    if (content.contains('part \'') || content.contains('part "')) {
      mainTestFiles.add(file);
    }
    if (content.contains('part of \'') || content.contains('part of "')) {
      partOfFiles.add(file);
    }
  }

  print('📁 Найдено:');
  print('   Основных файлов с part: ${mainTestFiles.length}');
  print('   Файлов с part of: ${partOfFiles.length}');

  /// Этап 2: Переименование файлов *_group.dart в *_test.dart
  final renamedFiles = <String, String>{};

  for (final file in partOfFiles) {
    if (file.path.contains('_group.dart')) {
      /// Улучшенная логика переименования:
      /// *_test_group.dart -> *_test.dart
      /// *_group.dart -> *_test.dart
      var newPath = file.path.replaceAll('_test_group.dart', '_test.dart');
      if (newPath == file.path) {
        // если замена не произошла
        newPath = file.path.replaceAll('_group.dart', '_test.dart');
      }

      if (dryRun) {
        print('📝 [DRY RUN] Переименование: ${file.path} -> $newPath');
      } else {
        print('📝 Переименование: ${file.path} -> $newPath');
        await file.rename(newPath);
      }
      renamedFiles[file.path] = newPath;
    }
  }

  if (dryRun) {
    print('\n🔍 DRY RUN завершен. Никаких изменений не внесено.');
    print('Для выполнения изменений запустите без --dry-run');
    return;
  }

  /// Этап 3: Обновление всех переименованных файлов
  final updatedFiles = <File>[];

  for (final oldPath in renamedFiles.keys) {
    final newPath = renamedFiles[oldPath]!;
    final file = File(newPath);

    await _processPartOfFile(file);
    updatedFiles.add(file);
  }

  /// Этап 4: Обработка helpers файлов (они остаются без переименования)
  for (final file in partOfFiles) {
    if (!file.path.contains('_group.dart')) {
      await _processHelperFile(file);
      updatedFiles.add(file);
    }
  }

  /// Этап 5: Обновление основных тестовых файлов
  for (final file in mainTestFiles) {
    await _processMainTestFile(file, renamedFiles);
  }

  print('');
  print('✅ Рефакторинг завершен!');
  print('🔄 Переименовано файлов: ${renamedFiles.length}');
  print('🔧 Обработано файлов: ${updatedFiles.length + mainTestFiles.length}');
  print('');
  print('🎯 Теперь каждый тест можно запускать независимо:');
  for (final newPath in renamedFiles.values) {
    if (newPath.contains('_test.dart')) {
      print('   flutter test $newPath');
    }
  }
}

/// Обрабатывает файл с part of, который был переименован из *_group.dart
Future<void> _processPartOfFile(File file) async {
  var content = await file.readAsString();
  final lines = content.split('\n');
  final newLines = <String>[];

  bool foundRunMethod = false;

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = line.trim();

    /// Удаляем part of
    if (trimmed.startsWith('part of ')) {
      continue;
    }

    /// Заменяем void run**Tests() на void main()
    if (trimmed.startsWith('void run') && trimmed.contains('Tests()')) {
      foundRunMethod = true;
      newLines.add(
          line.replaceFirst(RegExp(r'void\s+run\w*Tests\(\)'), 'void main()'));
      continue;
    }

    newLines.add(line);
  }

  /// Добавляем необходимые импорты в начало файла
  final importLines = _generateImportsForTestFile();
  final finalLines = <String>[];

  /// Добавляем импорты
  finalLines.addAll(importLines);
  finalLines.add('');

  /// Добавляем остальной контент
  finalLines.addAll(newLines);

  await file.writeAsString(finalLines.join('\n'));

  print(
      '   ✏️  ${file.path}: заменено ${foundRunMethod ? '1 метод' : '0 методов'} на main()');
}

/// Обрабатывает helper файл (моки, утилиты)
Future<void> _processHelperFile(File file) async {
  var content = await file.readAsString();
  final lines = content.split('\n');
  final newLines = <String>[];

  for (final line in lines) {
    final trimmed = line.trim();

    /// Удаляем part of
    if (trimmed.startsWith('part of ')) {
      continue;
    }

    newLines.add(line);
  }

  /// Добавляем необходимые импорты
  final importLines = _generateImportsForHelperFile();
  final finalLines = <String>[];

  finalLines.addAll(importLines);
  finalLines.add('');
  finalLines.addAll(newLines);

  await file.writeAsString(finalLines.join('\n'));

  print('   🔧 ${file.path}: обновлен helper файл');
}

/// Обрабатывает основной тестовый файл, удаляя part и вызовы run**Tests()
Future<void> _processMainTestFile(
    File file, Map<String, String> renamedFiles) async {
  var content = await file.readAsString();
  final lines = content.split('\n');
  final newLines = <String>[];

  int removedParts = 0;
  int removedCalls = 0;
  bool inMainFunction = false;

  for (final line in lines) {
    final trimmed = line.trim();

    /// Удаляем part директивы
    if (trimmed.startsWith("part '")) {
      removedParts++;
      continue;
    }

    /// Отслеживаем main() функцию
    if (trimmed.startsWith('void main()')) {
      inMainFunction = true;
    } else if (inMainFunction && trimmed == '}' && line.startsWith('}')) {
      inMainFunction = false;
    }

    /// Удаляем вызовы run**Tests() в main()
    if (inMainFunction &&
        trimmed.contains('Tests()') &&
        trimmed.startsWith('run')) {
      removedCalls++;
      continue;
    }

    newLines.add(line);
  }

  /// Очищаем пустые строки в main() если он остался пустым
  final finalLines = _cleanupMainFunction(newLines);

  await file.writeAsString(finalLines.join('\n'));

  print(
      '   🗑️  ${file.path}: удалено $removedParts parts, $removedCalls вызовов');
}

/// Очищает main() функцию от лишних пустых строк
List<String> _cleanupMainFunction(List<String> lines) {
  final result = <String>[];
  bool inMain = false;
  bool mainHasContent = false;

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = line.trim();

    if (trimmed.startsWith('void main()')) {
      inMain = true;
      result.add(line);

      /// Проверяем, есть ли контент в main()
      for (int j = i + 1; j < lines.length; j++) {
        final nextTrimmed = lines[j].trim();
        if (nextTrimmed == '}' && lines[j].startsWith('}')) break;
        if (nextTrimmed.isNotEmpty && !nextTrimmed.startsWith('group(')) {
          mainHasContent = true;
          break;
        }
      }
      continue;
    }

    if (inMain && trimmed == '}' && line.startsWith('}')) {
      /// Если main() пустой, добавляем комментарий
      if (!mainHasContent) {
        result.add('  // Тесты перенесены в отдельные файлы');
      }
      result.add(line);
      inMain = false;
      continue;
    }

    result.add(line);
  }

  return result;
}

/// Генерирует импорты для тестовых файлов
List<String> _generateImportsForTestFile() {
  return [
    "import 'package:flutter_test/flutter_test.dart';",
    "import 'package:mocktail/mocktail.dart';",
    "import 'package:app_update/app_update.dart';",
  ];
}

/// Генерирует импорты для helper файлов
List<String> _generateImportsForHelperFile() {
  return [
    "import 'package:flutter_test/flutter_test.dart';",
    "import 'package:mocktail/mocktail.dart';",
    "import 'package:package_info_plus/package_info_plus.dart';",
    "import 'package:app_update/app_update.dart';",
  ];
}

/// Рекурсивно получает все .dart файлы
Future<List<File>> _getAllDartFiles(Directory dir) async {
  final files = <File>[];

  await for (final entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      files.add(entity);
    }
  }

  return files;
}
