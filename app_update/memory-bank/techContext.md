# Tech Context: App Update Implementation

## Технический стек

### Core Framework
- **Flutter SDK**: >=3.0.0 <4.0.0
- **Dart Language**: Latest stable
- **Package Type**: Flutter library package

### Ключевые зависимости
```yaml
dependencies:
  flutter: sdk             # Flutter framework
  yaml: ^3.1.2            # YAML configuration parsing
  package_info_plus: ^8.3.0  # Platform app information
  pub_semver: ^2.2.0      # Semantic versioning support
  html: ^0.15.4           # HTML parsing (for web scraping)
  shared_preferences: ^2.2.2  # Local storage
  url_launcher: ^6.1.14   # URL launching capabilities
  store_checker: ^1.8.0   # Store detection
  collection: ^1.18.0     # Collection utilities
  http: ^1.2.2            # HTTP client
```

### Development & Testing
```yaml
dev_dependencies:
  flutter_test: sdk       # Flutter testing framework
  flutter_lints: ^3.0.0  # Dart/Flutter linting rules
  mocktail: ^1.0.0       # Mocking framework
  project_kit: path       # Internal tooling
  clock: ^1.1.1          # Time manipulation for tests
  path: ^1.8.0           # Path manipulation utilities
```

## Архитектурные решения

### 1. Immutable Data Structures
Все data models используют immutable паттерн:
```dart
@immutable
class UpdateContentData {
  final String updateUrl;
  final String title;
  final String description;
  // ... immutable fields
  
  const UpdateContentData({...});
}
```

### 2. Mergeable Pattern для Rules
```dart
abstract class Mergeable<T extends Mergeable<T>> {
  T merge(T other);
}

class UpdateContentConfig implements Mergeable<UpdateContentConfig> {
  @override
  UpdateContentConfig merge(covariant UpdateContentConfig other) =>
    UpdateContentConfig.byRequired(
      updateUrl: other.updateUrl ?? updateUrl,
      title: other.title ?? title,
      // ... merge logic
    );
}
```

### 3. Type-Safe Configuration Parsing
Строгая типизация всех конфигураций:
```dart
class UpdateConfigParser {
  UpdateConfig? parse(Object? value, {required bool isDebug}) {
    // Валидация типов с детальными ошибками
    if (value is! Map) {
      throw ParseConfigException.wrongType(
        rightType: Map,
        wrongType: value.runtimeType,
        parserType: UpdateConfigParser,
        configs: [value],
      );
    }
    // ...
  }
}
```

### 4. Stream-Based Architecture
Реактивная архитектура с Stream API:
```dart
abstract interface class UpdateController {
  Stream<void> get onFetch;  // Уведомления о загрузке данных
}
```

### 5. Platform Adaptation
Автоматическая адаптация под платформу:
```dart
factory UpdatePlatform.current() => UpdatePlatform._(
  kIsWeb ? web.name : Platform.operatingSystem,
);
```

## Сложные технические решения

### 1. Dynamic Date Resolution
Система динамических дат с fallback:
```dart
DateTime? baseDate = ruleDate.date;
baseDate ??= switch (ruleDate) {
  UpdateDate.localReleaseDate => localReleaseDate,
  UpdateDate.updateReleaseDate => updateReleaseDate,
  UpdateDate.appUpdateDate => appUpdateDate,
  UpdateDate.appInstallDate => appInstallDate,
  _ => null,
};
```

### 2. Rule Priority System
Система приоритетов правил с merging:
```dart
List<UpdateRuleConfig<T>>? linkRules<T extends Mergeable<T>>(
  List<UpdateRuleConfig<T>>? rules,
) => rules?.map((rule) => _linkRule(
  rule: rule,
  source: globalSource,
  platform: globalSourcePlatform,
)).toList();

final finalContentRules = Mergeable.mergeRules(
  rulesContainer.contentRules,           // Базовые правила
  linkRules(globalSource?.contentRules), // Правила источника
  linkRules(globalSourcePlatform?.contentRules), // Правила платформы
  update.contentRules,                   // Правила обновления
);
```

### 3. Complex Source-Platform Matching
Сложная логика сопоставления источников и платформ:
```dart
bool _isSourceSupportsPlatform(
  UpdateSource ruleSource,
  UpdatePlatform searchPlatform,
  UpdateSource searchSource,
) {
  final rulePlatforms = ruleSource.platforms ?? searchSource.platforms;
  if (rulePlatforms == null) {
    if (searchSource.platforms == null) return true;
    return false;
  }
  return rulePlatforms.contains(UpdatePlatform.any) ||
         rulePlatforms.contains(searchPlatform);
}
```

### 4. Interpolation Engine
Система подстановки переменных в контент:
```dart
String _interpolateString<T extends String?>(
  T text,
  Map<String, String> interpolateData,
) {
  if (text == null) return text;
  String str = text;
  for (final entry in interpolateData.entries) {
    final regExp = _regExpForField(entry.key);
    str = str.replaceAll(regExp, entry.value);
  }
  return str as T;
}

static RegExp _regExpForField(String name) =>
  RegExp('\\\$$name|{$name}|\\\${$name}');
```

## Производительность и оптимизация

### 1. Lazy Loading
```dart
@protected
late final UpdateResolver updateResolver = UpdateResolver(
  ruleResolver: ruleResolver,
  contentInterpolator: contentInterpolator,
);
```

### 2. Efficient Sorting
Оптимизированная сортировка обновлений:
```dart
List<UpdateData> sortUpdates(List<UpdateData> updates, UpdateSearchData searchData) {
  return updates.sorted((a, b) {
    final byVersionDesc = b.version.compareTo(a.version);
    if (byVersionDesc != 0) return byVersionDesc;
    
    // При равной версии - по приоритету источника
    final aIdx = searchData.sources.indexWhere((e) => e.sourceName == a.sourceName);
    final bIdx = searchData.sources.indexWhere((e) => e.sourceName == b.sourceName);
    return aSafe.compareTo(bSafe);
  });
}
```

### 3. Memory Management
- **const constructors** где возможно
- **Reusable instances** для парсеров и матчеров
- **Efficient Collections** с использованием collection package

## Обработка ошибок

### 1. Typed Exceptions
```dart
sealed class UpdateStatus {
  final UpdateStatusType type;
}

abstract class UpdateException extends UpdateStatus implements Exception {
  const UpdateException({required super.type});
}
```

### 2. Graceful Degradation
```dart
final updates = await fetchUpdates(locale: locale, packageInfo: packageInfo)
  .onError<Object>((e, s) {
    Future.error(e, s);
    return []; // Fallback to empty list
  });
```

### 3. Detailed Error Context
```dart
ParseConfigException.wrongType({
  required Type rightType,
  required Type wrongType,
  required this.parserType,
  required this.configs,
}) : message = 'Wrong type: $wrongType, expected: $rightType';
```

## Тестирование

### 1. Comprehensive Test Coverage
```
test/
├── controller/           # UpdateController тесты
├── fetcher/             # Fetcher тесты с моками
├── linker/              # Linker integration тесты
├── parser/              # Parser тесты с YAML fixtures
├── resolver/            # Rule resolution тесты
├── searcher/            # Search algorithm тесты
└── shared/              # Shared utilities тесты
```

### 2. Integration Testing
```
integration/
├── app_store_api_test.dart    # Реальные API тесты (не для CI)
└── utils/                     # Test utilities
```

### 3. Mock Strategy
```dart
class MockUpdateConfigSourceFetcher extends Mock implements UpdateConfigSourceFetcher {
  @override
  UpdateSource get source => UpdateSource.googlePlay;
  
  @override
  Future<List<UpdateData>> fetchUpdates({...}) async => [];
}
```

## API Design

### 1. Fluent Interface
```dart
UpdateController(
  fetchers: [
    ...UpdateConfigSourceFetcher.defaultFetchers,
    UpdateConfigFetcher.byUrl(Uri.parse('https://example.com/config.yaml')),
  ],
)
```

### 2. Configuration-Driven
Все поведение управляется через YAML конфигурации без изменения кода.

### 3. Type Safety
Полная типизация всех API с compile-time проверками.

## Deployment и Distribution

### 1. Package Structure
```
lib/
├── app_update.dart          # Public API exports
└── src/                     # Implementation details
    ├── controller/
    ├── entities/
    ├── fetcher/
    ├── linker/
    ├── models/
    ├── parser/
    ├── resolver/
    ├── searcher/
    ├── storage/
    ├── utils/
    └── widgets/
```

### 2. Documentation
- **API v3 Documentation** - полное описание возможностей
- **Code examples** в example/ директории
- **Integration guides** для быстрого старта

### 3. Versioning Strategy
Семантическое версионирование с careful API evolution.
