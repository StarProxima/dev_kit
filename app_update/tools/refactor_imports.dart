#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';

/// Скрипт для рефакторинга импортов app_update/src в единый barrel import
void main(List<String> args) async {
  if (args.isEmpty) {
    print('Использование: dart run tools/refactor_imports.dart <директория>');
    print('Пример: dart run tools/refactor_imports.dart test/');
    exit(1);
  }

  final targetDir = Directory(args[0]);

  if (!targetDir.existsSync()) {
    print('❌ Ошибка: Директория ${args[0]} не найдена');
    exit(1);
  }

  print('🔄 Рефакторинг импортов в директории: ${targetDir.path}');

  /// Получаем все .dart файлы из целевой директории рекурсивно
  final dartFiles = await _getAllDartFiles(targetDir);

  if (dartFiles.isEmpty) {
    print('📁 Не найдено .dart файлов в директории');
    return;
  }

  int processedFiles = 0;
  int modifiedFiles = 0;

  for (final file in dartFiles) {
    final result = await _processFile(file);
    processedFiles++;

    if (result.modified) {
      modifiedFiles++;
      print('✏️  ${file.path}: удалено ${result.removedImports} импортов');
    }
  }

  print('');
  print('✅ Рефакторинг завершен!');
  print('📊 Обработано файлов: $processedFiles');
  print('🔧 Изменено файлов: $modifiedFiles');
}

/// Результат обработки файла
class ProcessResult {
  final bool modified;
  final int removedImports;

  ProcessResult({required this.modified, required this.removedImports});
}

/// Обрабатывает один файл
Future<ProcessResult> _processFile(File file) async {
  final content = await file.readAsString();
  final lines = content.split('\n');

  final newLines = <String>[];
  bool hasAppUpdateImport = false;
  int removedImports = 0;
  bool modified = false;

  for (final line in lines) {
    final trimmedLine = line.trim();

    /// Проверяем существующий barrel import
    if (trimmedLine.startsWith("import 'package:app_update/app_update.dart'")) {
      hasAppUpdateImport = true;
      newLines.add(line);
      continue;
    }

    /// Удаляем импорты из app_update/src
    if (_isAppUpdateSrcImport(trimmedLine)) {
      removedImports++;
      modified = true;
      continue;
    }

    newLines.add(line);
  }

  /// Добавляем barrel import если его нет и были удалены импорты
  if (!hasAppUpdateImport && removedImports > 0) {
    /// Находим место для вставки импорта (после других импортов или в начале)
    final insertIndex = _findImportInsertPosition(newLines);
    newLines.insert(
        insertIndex, "import 'package:app_update/app_update.dart';");
    modified = true;
  }

  /// Записываем изменения, если файл был модифицирован
  if (modified) {
    await file.writeAsString(newLines.join('\n'));
  }

  return ProcessResult(modified: modified, removedImports: removedImports);
}

/// Проверяет, является ли строка импортом из app_update/src
bool _isAppUpdateSrcImport(String line) {
  return line.startsWith('import ') &&
      (line.contains('package:app_update/src/') ||
          line.contains("'src/") ||
          line.contains('"src/'));
}

/// Находит позицию для вставки импорта
int _findImportInsertPosition(List<String> lines) {
  int lastImportIndex = -1;

  for (int i = 0; i < lines.length; i++) {
    final trimmed = lines[i].trim();

    /// Пропускаем комментарии и пустые строки в начале файла
    if (trimmed.isEmpty ||
        trimmed.startsWith('//') ||
        trimmed.startsWith('/*')) {
      continue;
    }

    /// Если это импорт, обновляем последний индекс
    if (trimmed.startsWith('import ') || trimmed.startsWith('export ')) {
      lastImportIndex = i;
      continue;
    }

    /// Если дошли до не-импорта, прекращаем поиск
    break;
  }

  /// Вставляем после последнего импорта или в начало файла
  return lastImportIndex == -1 ? 0 : lastImportIndex + 1;
}

/// Рекурсивно получает все .dart файлы из директории
Future<List<File>> _getAllDartFiles(Directory dir) async {
  final files = <File>[];

  await for (final entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      files.add(entity);
    }
  }

  return files;
}
