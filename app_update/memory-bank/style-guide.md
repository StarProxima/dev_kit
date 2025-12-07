# Style Guide: App Update Library


### Важно
В конце всегда проверяй новый код через dcm analyze <dir> и исправляй проблемы.

Используй dart fix <dir> --apply, dcm fix <dir> и  dcm fix <dir> --unsafe, чтобы автоматом исправить некоторые ошибки.

После фиксов проверяй вручную, все ли ок. Или правь линты, или игнорь их, если кажется что так лучше.

## Dart/Flutter Code Style

### 1. Naming Conventions

#### Classes
```dart
// ✅ Good - PascalCase для классов
class UpdateController {}
class UpdateConfigFetcher {}
class AppStatusMatcher {}

// ❌ Bad
class updateController {}
class update_config_fetcher {}
```

#### Files
```dart
// ✅ Good - snake_case для файлов
update_controller.dart
update_config_fetcher.dart
app_status_matcher.dart

// ❌ Bad  
UpdateController.dart
updateController.dart
```

#### Variables и Methods
```dart
// ✅ Good - camelCase
final updateController = UpdateController();
Future<void> fetchConfigs() async {}

// ❌ Bad
final update_controller = UpdateController();
Future<void> fetch_configs() async {}
```

### 2. Constructor Patterns

#### Named Constructors
```dart
// ✅ Good - используем named constructors для clarity
const UpdateContentConfig.byRequired({
  required this.updateUrl,
  required this.title,
  required this.description,
  // ...
});

// Factory constructors для external creation
factory UpdateController({
  List<UpdateConfigFetcher> fetchers = UpdateConfigSourceFetcher.defaultFetchers,
}) => UpdateControllerImpl(fetchers: fetchers);
```

#### Const Constructors
```dart
// ✅ Good - const где возможно
const UpdateRuleConfig({
  this.appStatusIs,
  this.localeIs,
  required this.data,
});
```

### 3. Documentation

#### Class Documentation
```dart
/// Контроллер для поиска обновлений
///
/// You can add custom fetchers
/// ```dart
/// UpdateController(
///   fetchers: [
///     ...UpdateConfigSourceFetcher.defaultFetchers,
///     UpdateConfigFetcher.byUrl(...),
///   ],
/// )
/// ```
abstract interface class UpdateController {
```

#### Method Documentation
```dart
/// Ищет последние подходящие обновления для конкретной платформы и источника,
/// учитывая фильтры по версии и дате.
///
/// При одинаковой версии сортирует по приоритету источника согласно порядку в [UpdateSearchData.sources].
List<UpdateData> findAvailableUpdates({
  required UpdateSearchData searchData,
  required List<UpdateData> updates,
}) {
```

### 4. Error Handling

#### Custom Exceptions
```dart
class ParseConfigException implements Exception {
  final String? message;
  final List<Object> configs;
  final Type? parserType;
  
  // Named constructor для typed errors
  ParseConfigException.wrongType({
    required Type rightType,
    required Type wrongType,
    required this.parserType,
    required this.configs,
  }) : message = 'Wrong type: $wrongType, expected: $rightType';
}
```

#### Error Context
```dart
// ✅ Good - предоставляем контекст ошибки
throw ParseConfigException.wrongType(
  rightType: String,
  wrongType: value.runtimeType,
  parserType: AppStatusParser,
  configs: [value],
);
```

### 5. Lint Rules Compliance

#### Избегаем dynamic
```dart
// ✅ Good
Object? parse(Object? value) {

// ❌ Bad
dynamic parse(dynamic value) {
```

#### Используем type-safe casts
```dart
// ✅ Good
if (value is! Map<String, dynamic>) {
  throw ParseConfigException.wrongType(/*...*/);
}
final map = value;

// ❌ Bad  
final map = value as Map<String, dynamic>;
```

## Configuration Style

### 1. YAML Structure
```yaml
# ✅ Good - четкая структура с комментариями
content:
  # Базовые правила для всех платформ
  - view_target_is: any
    data:
      title: "Update Available"
      description: "New version available"
      
  # Локализация для русского языка
  - locale_is: ru
    data:
      title: "Доступно обновление"
```

### 2. Rule Ordering
```yaml
# ✅ Good - от общих к специфичным правилам
settings:
  # 1. Базовые настройки для всех
  - app_status_is: any
    data:
      should_show: false
      
  # 2. Специфичные для статусов
  - app_status_is: unsupported
    data:
      can_skip: false
      can_postpone: false
      
  # 3. Очень специфичные комбинации
  - app_status_is: deprecated
    view_target_is: screen
    data:
      should_show: true
```

### 3. Variable Naming
```yaml
# ✅ Good - используем snake_case в YAML
app_status_is: outdated
view_target_is: card
locale_is: ru
delay_hours: 24
gradual_rollout_hours: 72
user_segmentation_percent: 25

# ❌ Bad
appStatusIs: outdated
viewTargetIs: card
delayHours: 24
```

## Testing Patterns

### 1. Arrange-Act-Assert Structure
```dart
test('должен правильно применять локализацию', () async {
  // Arrange
  const yamlConfig = '''
  content:
    - locale_is: ru
      data:
        title: "Русский заголовок"
  ''';
  
  // Act
  final result = controller.findUpdate(searchConfig);
  
  // Assert
  expect(result.update!.content.title, 'Русский заголовок');
});
```

### 2. Helper Functions
```dart
// ✅ Good - переиспользуемые helpers
UpdateData createUpdateData({
  required Version version,
  DateTime? date,
  required UpdateSourceName sourceName,
  required UpdatePlatform platform,
}) {
  return UpdateData(
    version: version,
    date: date ?? DateTime.now(),
    sourceName: sourceName,
    platform: platform,
    // ...
  );
}
```

### 3. Mock Usage
```dart
// ✅ Good - используем mocktail для внешних зависимостей
class MockUpdateConfigSourceFetcher extends Mock implements UpdateConfigSourceFetcher {
  @override
  UpdateSource get source => UpdateSource.googlePlay;
  
  @override
  Future<List<UpdateData>> fetchUpdates({...}) async => [];
}
```

## File Organization

### 1. Directory Structure
```
src/
├── controller/      # High-level coordination
├── entities/        # Domain entities (value objects)
├── fetcher/         # Data fetching (external APIs)
├── linker/          # Data transformation and linking
├── models/          # Data models and configurations
├── parser/          # Configuration parsing
├── resolver/        # Rule resolution and content interpolation
├── searcher/        # Update searching and filtering
├── storage/         # Local data persistence
├── utils/           # Shared utilities
└── widgets/         # UI components
```

### 2. Import Organization
```dart
// ✅ Good - group imports
import 'dart:async';                    // Dart core
import 'dart:ui';

import 'package:flutter/material.dart'; // External packages
import 'package:package_info_plus/package_info_plus.dart';

import '../entities/app_status.dart';   // Internal imports
import '../models/update_config/update_config.dart';
```

### 3. Export Structure
```dart
// app_update.dart - single entry point with organized exports
library app_update;

export 'src/controller/update_contoller.dart';
export 'src/controller/update_controller_impl.dart';
// ... grouped by functionality
```

## Performance Guidelines

### 1. Const Usage
```dart
// ✅ Good - const везде где возможно
static const defaultMatchers = <RuleMatcher>[
  ViewTargetMatcher(),
  LocaleMatcher(),
  SourceMatcher(),
  // ...
];
```

### 2. Late Initialization
```dart
// ✅ Good - lazy initialization для expensive objects
@protected
late final UpdateResolver updateResolver = UpdateResolver(
  ruleResolver: ruleResolver,
  contentInterpolator: contentInterpolator,
);
```

### 3. Efficient Collections
```dart
// ✅ Good - используем collection package для performance
import 'package:collection/collection.dart';

final sortedUpdates = updates.sorted((a, b) => b.version.compareTo(a.version));
```

## Security Considerations

### 1. Input Validation
```dart
// ✅ Good - валидация всех входных данных
if (value is! String) {
  throw ParseConfigException.wrongType(
    rightType: String,
    wrongType: value.runtimeType,
    parserType: StringParser,
    configs: [value],
  );
}
```

### 2. Safe URL Construction
```dart
// ✅ Good - безопасное создание URL
return Uri.https(
  'play.google.com',
  'store/apps/details',
  {'id': packageInfo.packageName},
);
```

### 3. Sanitization
```dart
// ✅ Good - очистка входных данных
String get name => _name.replaceAll(' ', '').toLowerCase();
```

## Documentation Standards

### 1. README Structure
- **Quick start** с минимальным примером
- **Configuration examples** для основных сценариев  
- **API reference** с детальным описанием
- **Migration guides** между версиями

### 2. Code Comments
```dart
/// Преобразует релизы в конкретные обновления с источником и платформой
/// и мержит все правила.
///
/// [sources] — список источников, используются для получения дефолтных платформ.
/// Если [ReleaseSourceConfig.platforms] null (но не []), то платформы будет созданы
/// из [UpdateSource.platforms] через [ReleasePlatformConfig] для каждого источника.
List<UpdateData> linkAll({...}) {
```

### 3. Example Documentation
```dart
/// ```dart
/// UpdateController(
///   fetchers: [
///     ...UpdateConfigSourceFetcher.defaultFetchers,
///     UpdateConfigFetcher.byUrl(...),
///   ],
/// )
/// ```
```
