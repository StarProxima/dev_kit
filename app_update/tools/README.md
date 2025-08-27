# Tools

## generate_exports.dart

Dart скрипт для автоматической генерации файла экспортов `lib/app_update.dart`.

Скрипт:
- Рекурсивно проходит по всем файлам в директории `lib/src/`
- Находит все `.dart` файлы
- Генерирует `export` statements для каждого файла
- Обновляет файл `lib/app_update.dart`

### Использование

```bash
# Из корня проекта app_update
dart run tools/generate_exports.dart

# Или через shell обертку
./tools/generate.sh
```

### Пример вывода

```
Генерация файла экспортов...
✅ Файл app_update.dart обновлен!
📁 Найдено 105 файлов:
  - src/controller/update_contoller_base.dart
  - src/controller/update_controller.dart
  ...
```

## refactor_imports.dart

Dart скрипт для рефакторинга импортов из `app_update/src` в единый barrel import.

Скрипт:
- Рекурсивно проходит по всем файлам в указанной директории
- Находит все импорты из `package:app_update/src/` и `src/`
- Удаляет эти импорты
- Добавляет `import 'package:app_update/app_update.dart';` если его еще нет

### Использование

```bash
# Из корня проекта app_update
dart run tools/refactor_imports.dart <директория>

# Пример: рефакторинг всех тестов
dart run tools/refactor_imports.dart test/

# Или через shell обертку
./tools/refactor.sh test/
```

### Пример вывода

```
🔄 Рефакторинг импортов в директории: test/
✏️  test/fetcher/fetcher_test.dart: удалено 17 импортов
✅ Рефакторинг завершен!
📊 Обработано файлов: 39
🔧 Изменено файлов: 6
```
