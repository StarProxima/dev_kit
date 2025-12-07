# Example App Architecture

## 🎯 Overview

Sandbox приложение для тестирования библиотеки `app_update` построено по **feature-based архитектуре** с четким разделением слоев.

## 📐 Архитектурные принципы

### 1. Feature-Based Organization
Каждая feature находится в своей папке со всеми необходимыми слоями:
- **home** - главный экран с тестовыми сценариями
- **settings** - настройки sandbox
- **update_info** - детальная информация об обновлениях
- **shared** - общие компоненты

### 2. Layer Separation
Четкое разделение ответственности по слоям:

```
features/
  └── feature_name/
      ├── domain/         # Бизнес-логика и модели
      ├── presentation/   # UI компоненты
      └── data/           # Внешние источники данных (будущее)
```

### 3. Dependency Rule
```
presentation → domain → data
```
- Presentation зависит от domain
- Domain независим от остальных слоев
- Data реализует интерфейсы из domain

## 📦 Структура features

### home/
Главный экран с тестовыми сценариями.

**domain/**
- `update_scenario.dart` - Модель тестового сценария с предопределенными вариантами

**presentation/**
- `home_screen.dart` - Главный экран (только UI, логика в notifier)
- `widgets/info_card.dart` - Информационная карточка с настройками

### settings/
Экран настроек sandbox.

**domain/**
- `settings_notifier.dart` - ValueNotifier для управления временным состоянием настроек

**presentation/**
- `settings_screen.dart` - UI настроек (логика в notifier)

### update_info/
Детальная информация об обновлении.

**presentation/**
- `update_info_screen.dart` - Показ всех полей Update объекта (stateless)

### shared/
Общие компоненты используемые во всех features.

**data/**
- `config_loader.dart` - Загрузка YAML конфигов из assets (через rootBundle)

**domain/**
- `app_state.dart` - Глобальный доступ к состоянию (Singleton)
- `sandbox_state_notifier.dart` - ValueNotifier для управления состоянием sandbox
- `update_config_type.dart` - Enum для типов конфигураций

**presentation/widgets/**
- `scenario_card.dart` - Переиспользуемая карточка для сценариев

## 🔄 Data Flow

```
User Action
    ↓
Presentation (Screen/Widget)
    ↓
Domain (Models/Business Logic)
    ↓
External Library (app_update)
    ↓
Update State
    ↓
Rebuild UI
```

## 🎨 State Management

### SandboxStateNotifier (ValueNotifier)
- Основное состояние приложения
- Управляет UpdateController (пересоздает при смене конфига)
- Вся бизнес-логика вынесена из виджетов

```dart
// Доступ через singleton
final notifier = AppState.instance.notifier;

// Reactive UI через ValueListenableBuilder
ValueListenableBuilder(
  valueListenable: AppState.instance.notifier,
  builder: (context, state, child) {
    return Text(state.locale.toString());
  },
)
```

### SettingsNotifier (ValueNotifier)
- Временное состояние для редактирования настроек
- Локальный notifier для экрана настроек
- При сохранении применяет изменения к SandboxStateNotifier

### State Architecture Benefits
- ✅ **Отделение логики от UI** - виджеты только отображают
- ✅ **Реактивность** - автоматическое обновление UI
- ✅ **Тестируемость** - логику можно тестировать отдельно
- ✅ **Пересоздание контроллера** - при смене конфига автоматически

## 🧩 Key Patterns

### 1. Domain Models
Чистые модели без UI логики:
```dart
class UpdateScenario {
  final String id;
  final String title;
  final IconData icon; // Допустимо для презентационных моделей
  final Color color;
  final String configFile;
}

// Enum для типов конфигураций
enum UpdateConfigType {
  optional('test_optional_update.yaml'),
  critical('test_critical_update.yaml'),
  recommended('test_recommended_update.yaml');
  
  const UpdateConfigType(this.fileName);
  final String fileName;
}
```

### 2. Widget Composition
Композиция мелких переиспользуемых виджетов:
```dart
HomeScreen
  ├── InfoCard
  └── ScenarioCard (x multiple)
```

### 3. Presentation Logic in Notifiers
Бизнес-логика вынесена в ValueNotifier:
```dart
class SandboxStateNotifier extends ValueNotifier<SandboxState> {
  Future<void> checkForUpdates() async {
    // Вся логика проверки обновлений
  }
  
  Future<void> changeConfigType(UpdateConfigType configType) async {
    // Dispose старого контроллера
    await value.controller.dispose();
    
    // Создаем новый контроллер с новым конфигом
    final newController = _createController(configType);
    value = value.copyWith(configType: configType, controller: newController);
  }
}

// Виджет только вызывает методы notifier
class _HomeScreenState extends State<HomeScreen> {
  Future<void> _checkForUpdates() async {
    await _notifier.checkForUpdates(); // Делегируем в notifier
  }
}
```

## 📋 Best Practices

### ✅ DO
- Группируй related files по features
- Разделяй concerns по слоям (domain/presentation)
- Используй composition вместо inheritance
- Держи widgets маленькими и focused
- Shared компоненты в отдельной feature

### ❌ DON'T
- Не смешивай UI и бизнес-логику
- Не создавай глубокие widget trees
- Не дублируй код между features
- Не используй direct dependencies между features

## 🚀 Extensibility

### Добавление новой feature:
```
lib/features/
  └── new_feature/
      ├── domain/
      │   └── models.dart
      └── presentation/
          ├── new_feature_screen.dart
          └── widgets/
              └── custom_widget.dart
```

### Добавление data layer:
```
lib/features/
  └── feature_name/
      ├── data/
      │   ├── repositories/
      │   ├── datasources/
      │   └── models/
      ├── domain/
      └── presentation/
```

## 🔗 Integration Points

### app_update Library
- Используется через `UpdateController`
- Интеграция в `app.dart` через `UpdateHandler.alert`
- Модели из библиотеки используются в presentation слое

### Config Files
- YAML конфиги в `config/` директории
- Загружаются через `UpdateConfigFetcher`
- Связаны с `UpdateScenario` моделями

## 📚 References

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Feature-First Organization](https://codewithandrea.com/articles/flutter-project-structure/)

