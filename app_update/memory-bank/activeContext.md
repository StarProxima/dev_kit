# Active Context: App Update Library

## Текущее состояние проекта

### Git Status
- **Branch**: app-update-reborn
- **Status**: Ahead of origin by 3 commits
- **Working Tree**: Clean (ready for development)

### Последняя активность
- Проект находится в стадии активной разработки
- Недавние изменения включают обновления основной архитектуры
- Все тесты в актуальном состоянии

## Основные компоненты проекта

### 1. Core Library Structure
```
lib/
├── app_update.dart                    # Main entry point
└── src/
    ├── controller/                    # Update orchestration
    │   ├── update_contoller.dart      # Interface
    │   └── update_controller_impl.dart # Implementation
    ├── entities/                      # Domain entities
    ├── fetcher/                       # Data fetching
    ├── linker/                        # Data transformation
    ├── models/                        # Data models
    ├── parser/                        # YAML parsing
    ├── resolver/                      # Rule resolution
    ├── searcher/                      # Update search
    ├── storage/                       # Local persistence
    ├── utils/                         # Shared utilities
    └── ui/                            # UI components
        ├── update_alert_handler.dart  # Alert handler facade
        ├── update_handler.dart        # Main handler widget
        └── widgets/                   # UI widgets
            └── update_material_dialog.dart  # ✅ Material dialog
```

### 2. Configuration System
- **API v3** - текущая версия конфигурационного API
- **YAML-based** конфигурации с поддержкой правил
- **Multi-level** система правил (content, settings, app_settings)
- **Dynamic interpolation** переменных в контенте

### 3. Testing Infrastructure
```
test/
├── controller/ (comprehensive + extreme tests)
├── fetcher/ (with coordinator tests)
├── linker/ (integration tests)  
├── parser/ (sub-parsers tests)
├── resolver/ (rule matching tests)
└── searcher/ (algorithm tests)

integration/
└── app_store_api_test.dart (real API tests)
```

## Ключевые технические концепции

### 1. Rule-Based Configuration
Система правил с приоритизацией и merging:
- **Content rules** - контент UI (title, description, buttons)
- **Settings rules** - поведение UI (показ, действия пользователя)
- **App settings rules** - жизненный цикл версий и статусы

### 2. Multi-Source Support
Поддержка множественных источников обновлений:
- **Google Play Store** (Android)
- **Apple App Store** (iOS, macOS)
- **RuStore** (Android - российский магазин)
- **GitHub Releases** (все платформы)
- **TestFlight** (iOS, macOS - beta testing)
- **Custom sources** (расширяемость)

### 3. Platform Adaptation
Автоматическая адаптация под платформу:
- **Platform detection** через Flutter framework
- **Source detection** через store_checker package
- **URL generation** специфичное для каждой платформы

### 4. Temporal Rules Engine
Сложная система временных правил:
- **Dynamic dates** ($localReleaseDate, $updateReleaseDate)
- **Delay mechanism** - задержка активации правил
- **Progressive rollout** - постепенный выкат (0-100% пользователей)
- **User segmentation** - A/B тестирование

## Недавние изменения и эволюция

### API v3 Features
- Улучшенная система правил с более гибким синтаксисом
- Поддержка вложенных переопределений для источников и платформ
- Расширенная система interpolation переменных
- Улучшенная обработка ошибок с детальным контекстом

### Testing Improvements
- **Comprehensive tests** покрывают сложные сценарии
- **Integration tests** для реальных API (исключены из CI)
- **Mock strategy** для изоляции внешних зависимостей
- **Edge case coverage** для граничных условий

## Активные области разработки

### 1. Controller Implementation
```dart
// TODO items в UpdateControllerImpl:
Future<void> launchUpdateUrl(Update update) {
  // TODO: implement launchUpdateUrl
  throw UnimplementedError();
}

Future<void> postponeUpdate(Update update) {
  // TODO: implement postponeUpdate  
  throw UnimplementedError();
}

Future<void> skipUpdate(Update update) {
  // TODO: implement skipUpdate
  throw UnimplementedError();
}
```

### 2. Source Fetchers
```dart
// TODO в source fetchers:
Future<List<UpdateData>> fetchUpdates({
  required Locale locale,
  required PackageInfo packageInfo,
}) {
  // TODO: implement fetchUpdates
  throw UnimplementedError();
}
```

### 3. Widget Implementation
```dart
// ✅ РЕАЛИЗОВАНО UpdateAlertHandler.materialDialog
// Material Design диалог с полной функциональностью
static Future<void> materialDialog(...) {
  // ✅ Использует UpdateMaterialDialog widget
}

// TODO остальные виджеты:
// - primaryDialog, adaptiveDialog, cupertinoDialog
// - bottomModalSheet, screen, snackbar
// - pickUpdate
```

## Приоритетные задачи

### Высокий приоритет
1. **Завершение UpdateController** методов (launchUpdateUrl, postponeUpdate, skipUpdate)
2. **Реализация source fetchers** для получения real-time данных о версиях
3. **UI widgets implementation** для различных display targets

### Средний приоритет  
4. **Storage integration** с SharedPreferences для persistance
5. **Advanced interpolation** variables
6. **Error recovery** mechanisms

### Низкий приоритет
7. **Performance optimizations**
8. **Additional source types**
9. **Advanced analytics**

## Известные ограничения
- **Real API fetching** не реализовано (только URL generation)
- **UI widgets** находятся в стадии TODO
- **Storage operations** требуют доработки
- **Error recovery** может быть улучшен

## Интеграционные точки
- **Flutter apps** как основные потребители библиотеки
- **External APIs** (iTunes Search API, потенциально Google Play API)
- **Configuration files** (local/remote YAML files)
- **Local storage** через SharedPreferences
- **Platform stores** для actual update process
