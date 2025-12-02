# UI Widgets - Примеры использования

## Material Dialog

### Базовое использование

Material Dialog предоставляет стандартный Material Design диалог для отображения информации об обновлении.

```dart
import 'package:app_update/app_update.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Update Demo',
      home: UpdateHandler.alert(
        // Используем Material Dialog для показа обновлений
        onUpdateResult: UpdateAlertHandler.materialDialog,
        child: const HomeScreen(),
      ),
    );
  }
}
```

### Кастомная логика показа

Можно управлять когда показывать Material Dialog в зависимости от статуса обновления:

```dart
UpdateHandler.alert(
  onUpdateResult: (context, controller, result) {
    // Получаем обновление из результата
    final update = result.update;
    if (update == null) return;

    // Различная логика в зависимости от статуса
    switch (update.appSettings.appStatus) {
      case AppStatus.unsupported:
        // Критическое обновление - показываем немедленно
        UpdateAlertHandler.materialDialog(context, controller, result);
        
      case AppStatus.deprecated:
        // Устаревшая версия - показываем с задержкой
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) {
            UpdateAlertHandler.materialDialog(context, controller, result);
          }
        });
        
      case AppStatus.outdated:
        // Обычное обновление - показываем только если прошло время
        if (DateTime.now().difference(update.date ?? DateTime.now()) > 
            const Duration(days: 7)) {
          UpdateAlertHandler.materialDialog(context, controller, result);
        }
        
      default:
        // Для active и других статусов - не показываем
        break;
    }
  },
  child: const HomeScreen(),
)
```

### Прямое использование виджета

Можно использовать виджет напрямую, например в своем кастомном UI:

```dart
import 'package:app_update/app_update.dart';
import 'package:flutter/material.dart';

class CustomUpdateScreen extends StatelessWidget {
  const CustomUpdateScreen({
    super.key,
    required this.update,
    required this.controller,
  });

  final Update update;
  final UpdateController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Доступно обновление'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Показываем Material Dialog при нажатии
            showUpdateMaterialDialog(
              context: context,
              update: update,
              controller: controller,
            );
          },
          child: const Text('Показать информацию об обновлении'),
        ),
      ),
    );
  }
}
```

## Структура диалога

Material Dialog автоматически адаптируется под настройки обновления:

### Элементы диалога

1. **Заголовок** - `update.content.title`
2. **Описание** - `update.content.description`
3. **Release Notes** - `update.content.releaseNotes` (опционально)
4. **Кнопки действий** - зависят от `update.settings`:
   - **"Обновить"** - всегда показывается как primary action
   - **"Пропустить"** - показывается если `settings.canSkip == true`
   - **"Позже"** - показывается если `settings.canPostpone == true`

### Поведение закрытия диалога

Диалог автоматически обрабатывает закрытие:

- **Если `canPostpone == true`:**
  - Можно закрыть диалог кликом вне его (barrier)
  - Можно закрыть кнопкой "Назад"
  - При закрытии автоматически вызывается `controller.postponeUpdate(update)`

- **Если `canPostpone == false`:**
  - Диалог нельзя закрыть кликом вне его
  - Диалог нельзя закрыть кнопкой "Назад"
  - Пользователь должен выбрать одно из доступных действий

### Поведение кнопок

```dart
// Кнопка "Обновить" - открывает store URL
onPressed: () async {
  Navigator.of(context).pop(true); // Явное действие
  await controller.launchUpdateUrl(update);
}

// Кнопка "Пропустить" - сохраняет решение пропустить это обновление
onPressed: () async {
  Navigator.of(context).pop(true); // Явное действие
  await controller.skipUpdate(update);
}

// Кнопка "Позже" - откладывает показ обновления
onPressed: () async {
  Navigator.of(context).pop(true); // Явное действие
  await controller.postponeUpdate(update);
}

// Закрытие диалога через barrier или back button (если canPostpone = true)
// Автоматически вызывает controller.postponeUpdate(update)
```

## Конфигурация через YAML

Настройка внешнего вида и поведения диалога через конфигурацию:

```yaml
# Настройка контента
content:
  - when: { locale_is: ru }
    data:
      title: "Доступно обновление"
      description: "Версия $releaseVersion готова к установке"
      updateButton: "Обновить"
      skipButton: "Пропустить"
      postponeButton: "Позже"
      releaseNotesTitle: "Что нового"
      releaseNotes: |
        - Улучшена производительность
        - Исправлены ошибки
        - Новые функции

# Настройка поведения
settings:
  - when: { app_status_is: deprecated }
    data:
      should_show: true
      can_skip: false      # Кнопка "Пропустить" не показывается
      can_postpone: true   # Кнопка "Позже" показывается
```

## Best Practices

### 1. Используйте правильный контекст

```dart
// ✅ Good - используем context из builder
UpdateHandler.alert(
  onUpdateResult: (context, controller, result) {
    UpdateAlertHandler.materialDialog(context, controller, result);
  },
  child: const HomeScreen(),
)

// ❌ Bad - не используем context из initState без проверки mounted
class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Может вызвать ошибку если context не готов
    UpdateAlertHandler.materialDialog(context, controller, result);
  }
}
```

### 2. Проверяйте mounted состояние

```dart
// ✅ Good - проверяем mounted перед показом диалога
Future.delayed(const Duration(seconds: 5), () {
  if (context.mounted) {
    UpdateAlertHandler.materialDialog(context, controller, result);
  }
});
```

### 3. Обрабатывайте null update

```dart
// ✅ Good - проверяем что update существует
onUpdateResult: (context, controller, result) {
  final update = result.update;
  if (update == null) {
    // Нет доступных обновлений
    return;
  }
  
  UpdateAlertHandler.materialDialog(context, controller, result);
}
```

### 4. Используйте статусы для логики

```dart
// ✅ Good - разная логика для разных статусов
onUpdateResult: (context, controller, result) {
  final update = result.update;
  if (update == null) return;

  // Критические обновления показываем сразу
  // canPostpone = false означает что диалог нельзя закрыть
  if (update.appSettings.appStatus == AppStatus.unsupported) {
    UpdateAlertHandler.materialDialog(context, controller, result);
    return;
  }

  // Остальные показываем с задержкой
  // canPostpone = true означает что можно отложить через barrier/back button
  Future.delayed(const Duration(seconds: 3), () {
    if (context.mounted) {
      UpdateAlertHandler.materialDialog(context, controller, result);
    }
  });
}
```

### 5. Понимайте влияние canPostpone

```dart
// ✅ Good - правильная настройка canPostpone через конфигурацию
```yaml
settings:
  # Критические обновления - нельзя отложить
  - when: { app_status_is: unsupported }
    data:
      should_show: true
      can_postpone: false  # ← Диалог нельзя закрыть без действия
      can_skip: false      # ← Все кнопки кроме "Обновить" скрыты
      
  # Рекомендуемые обновления - можно отложить
  - when: { app_status_is: [outdated, deprecated] }
    data:
      should_show: true
      can_postpone: true   # ← Можно закрыть через barrier/back button
      can_skip: true       # ← Показываются все кнопки
```
```

## Roadmap

Планируемые виджеты для будущих релизов:

- **Cupertino Dialog** - iOS-стиль диалог
- **Adaptive Dialog** - автоматический выбор Material/Cupertino
- **Material Card** - компактное представление в виде карточки
- **Bottom Sheet** - нижняя панель с информацией
- **Full Screen** - полноэкранный режим для критических обновлений
- **Snackbar** - ненавязчивое уведомление

