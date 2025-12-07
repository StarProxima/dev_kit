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

## refactor_tests.dart

Dart скрипт для полного рефакторинга структуры тестов с part/part of на независимые модули.

Скрипт:
- Рекурсивно анализирует структуру тестов в указанной директории
- Переименовывает файлы `*_group.dart` в `*_test.dart`
- Удаляет все `part`/`part of` директивы
- Заменяет их на соответствующие `import`
- Заменяет методы `run**Tests()` на `main()`
- Обновляет основные тестовые файлы

### Использование

```bash
# Dry-run для просмотра планируемых изменений
dart run tools/refactor_tests.dart --dry-run

# Выполнение рефакторинга для всех тестов
dart run tools/refactor_tests.dart

# Рефакторинг конкретной директории
dart run tools/refactor_tests.dart test/parser

# Через shell обертку
./tools/refactor_tests.sh
```

### Пример вывода

```
🔧 Рефакторинг структуры тестов в директории: test
📁 Найдено:
   Основных файлов с part: 6
   Файлов с part of: 32
📝 Переименование: test/parser/groups/release_config_parser_test_group.dart -> test/parser/groups/release_config_parser_test.dart
✏️ test/parser/groups/release_config_parser_test.dart: заменено 1 метод на main()
✅ Рефакторинг завершен!
🔄 Переименовано файлов: 26
🔧 Обработано файлов: 38
```

⚠️ **Внимание:** Этот скрипт кардинально изменяет структуру тестов. Рекомендуется сделать резервную копию перед использованием.
