# App Update Sandbox Example

Полнофункциональный sandbox для тестирования библиотеки `app_update` с различными сценариями обновлений.

## 📁 Архитектура

Проект организован по **feature-based** архитектуре с четким разделением слоев:

```
lib/
├── main.dart                      # Entry point
├── app.dart                       # Главное приложение с UpdateHandler
└── features/                      # Features по доменам
    ├── home/                      # Главный экран
    │   ├── domain/
    │   │   └── update_scenario.dart        # Модель тестового сценария
    │   └── presentation/
    │       ├── home_screen.dart            # Главный экран sandbox
    │       └── widgets/
    │           └── info_card.dart          # Информационная карточка
    ├── settings/                  # Настройки
    │   └── presentation/
    │       └── settings_screen.dart        # Экран настроек
    ├── update_info/               # Информация об обновлении
    │   └── presentation/
    │       └── update_info_screen.dart     # Детальная информация
    └── shared/                    # Общие компоненты
        ├── domain/
        │   └── app_state.dart              # Глобальное состояние
        └── presentation/
            └── widgets/
                └── scenario_card.dart      # UI карточки сценария
```

### Слои архитектуры

#### Data
- Загрузка данных из внешних источников
- Примеры: `ConfigLoader` (загрузка YAML из assets)

#### Domain
- Бизнес-логика и модели данных
- State management (ValueNotifiers)
- Независимы от UI фреймворка
- Примеры: `SandboxStateNotifier`, `SettingsNotifier`, `UpdateScenario`, `UpdateConfigType`

#### Presentation
- UI компоненты (screens, widgets)
- Только отображение, вся логика в domain
- Примеры: `HomeScreen`, `SettingsScreen`, `ScenarioCard`

## 🎯 Возможности Sandbox

### Основные действия

1. **Проверить обновления**
   - Проверка наличия обновлений с текущими настройками
   - Отображение результата в snackbar

2. **Показать Material Dialog**
   - Демонстрация стандартного Material Design диалога
   - Поддержка всех action buttons (update, skip, postpone)

3. **Информация об обновлении**
   - Детальная информация о последнем результате проверки
   - Все поля контента, настроек и статусов

### Тестовые сценарии

#### 1. Критическое обновление
- Конфиг: `lib/configs/test_critical_update.yaml`
- Статус: `unsupported`
- Возможности: нельзя пропустить или отложить
- Загружается через `UpdateConfigFetcher.byFile()`

#### 2. Рекомендуемое обновление
- Конфиг: `lib/configs/test_recommended_update.yaml`
- Статус: `deprecated`
- Возможности: можно отложить
- Загружается через `UpdateConfigFetcher.byFile()`

#### 3. Опциональное обновление
- Конфиг: `lib/configs/test_optional_update.yaml`
- Статус: `outdated`
- Возможности: можно пропустить или отложить
- Загружается через `UpdateConfigFetcher.byFile()`

### Настройки

- **Локаль**: en, ru, any
- **Конфигурация**: enum-based выбор тестового сценария
- **Версия приложения**: мок-версия для тестирования
- **Автопоказ диалога**: включить/выключить автоматический показ

**Важно:** При смене конфигурации `UpdateController` автоматически пересоздается с новым fetcher!

## 🎨 Design Patterns

### State Management
- **SandboxStateNotifier** - ValueNotifier для глобального состояния
- **SettingsNotifier** - ValueNotifier для временного состояния настроек
- Вся бизнес-логика в notifiers, виджеты только отображают

```dart
// Логика в notifier
class SandboxStateNotifier extends ValueNotifier<SandboxState> {
  Future<void> checkForUpdates() async { /* ... */ }
  Future<void> changeConfigType(UpdateConfigType type) async { /* ... */ }
}

// UI только вызывает методы
Future<void> _checkForUpdates() async {
  await _notifier.checkForUpdates();
}
```

### Controller Recreation
- При смене конфига старый контроллер dispose
- Создается новый контроллер с новым fetcher
- UpdateHandler автоматически получает новый контроллер

### Feature Organization
- Каждая feature в своей папке
- Четкое разделение по слоям (domain/presentation)
- Shared компоненты для переиспользования

### Widget Composition
- Мелкие переиспользуемые виджеты (`ScenarioCard`, `InfoCard`)
- Экраны композируют виджеты для построения UI
- ValueListenableBuilder для реактивности

## 🚀 Запуск

```bash
# Перейти в папку example
cd example

# Установить зависимости
flutter pub get

# Запустить на устройстве/эмуляторе
flutter run
```

## 📝 Добавление нового сценария

1. Добавить YAML конфиг в `lib/configs/`
2. Добавить сценарий в `UpdateScenario.scenarios`
3. Обновить `_getConfigFile()` в `HomeScreen` для маппинга ID на файл
4. Добавить название в `_getConfigName()` в `SettingsScreen`

### Пример:

```dart
// В update_scenario.dart
UpdateScenario(
  id: 'new_scenario',
  title: 'Новый сценарий',
  description: 'Описание сценария',
  icon: Icons.new_releases,
  color: Colors.indigo,
  configFile: 'test_new_scenario.yaml',
),
```

## 🔍 Полезные файлы

- `lib/configs/` - Тестовые YAML конфигурации (API v4)
- `features/shared/data/config_loader.dart` - Загрузка YAML из assets
- `features/shared/domain/sandbox_state_notifier.dart` - Бизнес-логика и state management
- `features/shared/domain/update_config_type.dart` - Enum типов конфигураций
- `features/home/domain/update_scenario.dart` - Модели сценариев
- `features/home/presentation/home_screen.dart` - UI главного экрана (только отображение)
- `app.dart` - Интеграция UpdateHandler с reactive controller

## 📚 Документация

- [App Update Library](../README.md)
- [API v4 Documentation](../memory-bank/docs/API_v4_Documentation.md)
- [UI Widgets Examples](../memory-bank/docs/ui_widgets_examples.md)
