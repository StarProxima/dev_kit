# System Patterns: App Update Architecture

## Архитектурные паттерны

### 1. Layered Architecture (Слоистая архитектура)
Проект организован в четкие слои с ясным разделением ответственности:

```
┌─────────────────────────────────────┐
│           PRESENTATION              │  ← widgets/ (UpdateHandler, UpdateAlertHandler)
├─────────────────────────────────────┤
│           CONTROLLER                │  ← controller/ (UpdateController, UpdateControllerImpl)
├─────────────────────────────────────┤
│           BUSINESS LOGIC            │  ← resolver/, linker/, searcher/
├─────────────────────────────────────┤
│           DATA PROCESSING           │  ← parser/, fetcher/
├─────────────────────────────────────┤
│           DATA PERSISTENCE          │  ← storage/
├─────────────────────────────────────┤
│           ENTITIES                  │  ← entities/, models/
└─────────────────────────────────────┘
```

### 2. Strategy Pattern
Множественные стратегии для разных аспектов:
- **UpdateConfigFetcher** - стратегии получения конфигураций (file, URL, custom)
- **UpdateConfigSourceFetcher** - стратегии для разных источников (GooglePlay, AppStore, RuStore)
- **RuleMatcher** - стратегии сопоставления правил (AppStatus, Locale, Source, etc.)

### 3. Rule Engine Pattern
Мощная система правил с приоритизацией:
```dart
// Правила применяются по порядку с возможностью переопределения
content:
  - view_target_is: any
    data: { title: "Default Title" }
  - locale_is: ru
    data: { title: "Russian Title" }  // Переопределяет для русской локали
```

### 4. Builder/Parser Pattern
Комплексная система парсинга YAML конфигураций:
- **UpdateConfigParser** - основной парсер
- **Sub-parsers** для каждого типа сущности
- **Primitive parsers** для базовых типов

### 5. Chain of Responsibility
**RuleMatcher** цепочка для валидации правил:
```dart
static const defaultMatchers = <RuleMatcher>[
  ViewTargetMatcher(),
  LocaleMatcher(), 
  SourceMatcher(),
  PlatformMatcher(),
  VersionMatcher(),
  AppStatusMatcher(),
  TemporalMatcher(),
  CustomParamsMatcher(),
];
```

### 6. Factory Pattern
Создание источников и сущностей:
```dart
factory UpdateController({
  List<UpdateConfigFetcher> fetchers = UpdateConfigSourceFetcher.defaultFetchers,
}) => UpdateControllerImpl(fetchers: fetchers);
```

## Ключевые системные компоненты

### Core Entities (Основные сущности)
```
entities/
├── app_status.dart           # Статусы версий (active, outdated, deprecated, unsupported)
├── update_date.dart          # Поддержка динамических дат ($localReleaseDate, $updateReleaseDate)
├── update_locale.dart        # Локализация (ru, en, any)
├── update_platform.dart      # Платформы (android, ios, macos, windows, linux, web)
├── update_source.dart        # Источники дистрибуции (googlePlay, appStore, ruStore, etc.)
├── update_view_target.dart   # UI таргеты (card, dialog, screen, etc.)
├── update_version_constraint.dart  # Версионные ограничения (semver)
└── update_entity.dart        # Базовая сущность для всех entity
```

### Data Flow Pipeline
```
Fetch → Parse → Link → Resolve → Search → Update
  ↓       ↓       ↓       ↓        ↓       ↓
Config   Rules   Data   Content  Result  Action
```

1. **Fetcher**: Получение конфигураций из разных источников
2. **Parser**: Преобразование YAML в типизированные объекты
3. **Linker**: Связывание релизов с источниками и платформами
4. **Resolver**: Применение правил и интерполяция данных
5. **Searcher**: Поиск подходящих обновлений
6. **Controller**: Координация всего процесса

### Configuration System (Система конфигураций)
**Четыре типа правил** с приоритизацией:

1. **Content Rules** - контент для UI
2. **Settings Rules** - поведение UI (показ, действия)
3. **App Settings Rules** - жизненный цикл версий
4. **Sources** - определение источников дистрибуции

### Temporal Logic (Временная логика)
Сложная система временных правил:
- **Dynamic dates**: `$localReleaseDate`, `$updateReleaseDate`
- **Delay**: задержка активации правила
- **Rollout**: прогрессивный выкат (0-100% пользователей)
- **Segmentation**: A/B тестирование (процент пользователей)

## Интеграционные точки

### External Dependencies
```yaml
dependencies:
  package_info_plus: ^8.3.0    # Информация о приложении
  pub_semver: ^2.2.0           # Семантические версии
  yaml: ^3.1.2                 # Парсинг конфигураций
  shared_preferences: ^2.2.2   # Локальное хранение
  url_launcher: ^6.1.14        # Запуск URL обновлений
  store_checker: ^1.8.0        # Определение источника установки
  http: ^1.2.2                 # HTTP запросы для API
```

### Internal APIs
- **iTunes Search API** для App Store данных
- **Custom fetchers** для других источников
- **File/URL based configs** для централизованного управления

## Паттерны безопасности

### Version Lifecycle Management
```
active → updateable → outdated → deprecated → unsupported
   ↑         ↑          ↑           ↑            ↑
 default   optional   recommended  required   blocking
```

### Progressive Rollout Safety
- **Segmentation** ограничивает количество затронутых пользователей
- **Delay** предотвращает немедленную активацию правил
- **Rollout duration** контролирует скорость распространения

### Configuration Validation
- **Typed models** предотвращают ошибки конфигурации
- **Debug mode** для детальной валидации
- **Exception handling** с понятными сообщениями об ошибках

## Масштабируемость

### Extensibility Points
1. **Custom UpdateConfigFetcher** - новые источники конфигураций
2. **Custom UpdateConfigSourceFetcher** - новые sources (stores)
3. **Custom RuleMatcher** - новые типы правил сопоставления
4. **Custom interpolation variables** - новые переменные для подстановки

### Performance Considerations
- **Lazy initialization** компонентов
- **Caching** результатов парсинга
- **Batch processing** множественных конфигураций
- **Memory-efficient** обработка больших конфигураций

## Качество и надежность

### Testing Strategy
- **Unit tests** для каждого компонента
- **Integration tests** для взаимодействия компонентов  
- **Comprehensive E2E tests** для сложных сценариев
- **Mock objects** для внешних зависимостей

### Error Handling
- **ParseConfigException** для ошибок конфигурации
- **UpdateException** для ошибок обновления
- **Graceful degradation** при недоступности источников
- **Fallback mechanisms** для критических операций
