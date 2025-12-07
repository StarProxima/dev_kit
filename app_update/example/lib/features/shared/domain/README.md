# Shared Domain Layer

## 📦 Компоненты

### app_state.dart
Singleton для глобального доступа к состоянию sandbox.

```dart
// Использование
final notifier = AppState.instance.notifier;
final state = notifier.value;
```

### sandbox_state_notifier.dart
ValueNotifier для управления состоянием приложения.

**Ключевые возможности:**
- Управление UpdateController (создание/пересоздание/dispose)
- Проверка обновлений
- Загрузка тестовых сценариев
- Реактивное обновление UI

**Важно:** При смене `configType` автоматически:
1. Dispose старого контроллера
2. Создается новый контроллер с новым fetcher
3. Инициализируется новый контроллер
4. State обновляется

```dart
// Пример использования
Future<void> changeConfigType(UpdateConfigType configType) async {
  await value.controller.dispose(); // Cleanup
  final newController = _createController(configType);
  await newController.init();
  
  value = value.copyWith(
    configType: configType,
    controller: newController,
  );
}
```

### settings_notifier.dart
ValueNotifier для временного состояния настроек.

**Паттерн:**
- Создается локально в SettingsScreen
- Инициализируется из SandboxStateNotifier
- Изменения применяются только при сохранении
- Dispose автоматически при закрытии экрана

```dart
// Workflow
1. User opens SettingsScreen
2. SettingsNotifier создается с current values
3. User редактирует настройки
4. User нажимает "Сохранить"
5. saveSettings() применяет изменения к SandboxStateNotifier
6. Screen закрывается, notifier dispose
```

### update_config_type.dart
Enum для типов конфигураций.

**Преимущества enum:**
- ✅ Type-safety (нельзя ошибиться в строке)
- ✅ Автокомплит в IDE
- ✅ Встроенные displayName и fileName
- ✅ Легко добавлять новые типы

```dart
enum UpdateConfigType {
  optional('test_optional_update.yaml'),
  critical('test_critical_update.yaml'),
  recommended('test_recommended_update.yaml');
  
  const UpdateConfigType(this.fileName);
  final String fileName;
  
  String get displayName { /* ... */ }
}
```

## 🔄 Data Flow

```
User Action
    ↓
Widget (только UI)
    ↓
Notifier (бизнес-логика)
    ↓
UpdateController
    ↓
State Update
    ↓
ValueListenableBuilder rebuilds UI
```

## 🎯 Best Practices

### ✅ DO
- Вся логика в notifiers
- Виджеты только вызывают методы notifier
- Используй ValueListenableBuilder для реактивности
- Dispose notifiers при удалении виджетов

### ❌ DON'T
- Не держи логику в State классах виджетов
- Не используй прямые вызовы setState с логикой
- Не забывай dispose контроллеры
- Не пропускай removeListener при dispose

