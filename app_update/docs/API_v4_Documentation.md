# App Update API v4

Система конфигураций для управления обновлениями приложения. Поддерживает правила контента, поведение UI, жизненный цикл версий, прогрессивная раскатка и мульти-источники дистрибуции.

## Быстрый старт

Минимальная конфигурация:

```yaml
content:
  - data:
      title: "Обновление доступно"
      description: "Версия $releaseVersion готова"

settings:
  - data:
      should_show: true

app_settings:
  - data:
      app_status: active

sources:
  - name: appStore
    platforms: [ios, macos]

releases:
  - version: 1.2.0
    date: "2024-08-24 15:35:00"
    content:
      - data:
          release_notes: "Улучшения и исправления"
    sources: [appStore]
```

## Структура конфигурации

```yaml
content:      # Контент для UI (тексты, кнопки)
settings:     # Поведение UI (показывать ли, можно ли пропустить)
app_settings: # Жизненный цикл версий (статусы, раскатка)
sources:      # Источники дистрибуции (сторы/платформы)
releases:     # Конкретные релизы приложения
```

## Базовые понятия

| Понятие | Значения | Описание |
|---------|----------|----------|
| **app_status** | `active`, `outdated`, `deprecated`, `unsupported`, `any` | Статус версии приложения |
| **view_target** | `card`, `dialog`, `screen`, `toast`, `aboutScreen`, `any` | Место отображения UI |
| **locale** | `ru`, `en`, ... или `any` | Код языка пользователя |
| **platform** | `android`, `ios`, `macos`, `windows`, `linux`, `web`, `any` | Платформа |
| **date** | `"2024-01-01 10:00:00"` или `"...Z"` (UTC) | Дата и время |
| **Динамические даты** | `$localReleaseDate`, `$updateReleaseDate` | Даты текущей и новой версии |

## Структура правил (when/rollout/data)

Каждое правило состоит из трёх секций:

```yaml
- when:                              # Условия применения
    view_target_is: card
    app_status_is: outdated
    locale_is: ru
    platform_is: android
    source_is: googlePlay
    app_version_is: ">=1.0.0 <2.0.0"
    custom_params:
      env_is: prod                   # Кастомные условия (суффикс _is)
      
  rollout:                           # Параметры раскатки (опционально)
    date: $updateReleaseDate         # Базовая дата
    delay_hours: 24                  # Задержка активации
    gradual_rollout_hours: 168       # Длительность раскатки
    user_segmentation_percent: 25    # Процент пользователей
    
  data:                              # Данные правила
    title: "Заголовок"
    custom_params:                   # Данные для приложения (без _is)
      analytics_event: "update_shown"
```

## Content Rules — контент UI

```yaml
content:
  # Базовый контент (английский)
  - data:
      title: "Update $appName"
      description: "Version $releaseVersion available"
      update_button: "Update"
      skip_button: "Skip"
      postpone_button: "Later"

  # Русская локализация
  - when: { locale_is: ru }
    data:
      title: "Обновите $appName"
      description: "Версия $releaseVersion доступна"
      update_button: "Обновить"

  # Критические обновления
  - when:
      app_status_is: [deprecated, unsupported]
      locale_is: ru
    data:
      title: "Важное обновление"
      description: "Обновитесь как можно скорее"

  # Платформо-специфичный контент
  - when:
      platform_is: android
      source_is: googlePlay
    data:
      update_button: "Open Play Store"
```

Поддерживаются произвольные поля в `data`:

```yaml
data:
  custom_params:
    image:
      url: https://example.com/banner.png
      border_radius: 10
```

## Settings Rules — поведение UI

```yaml
settings:
  # Базовые настройки: скрыто по умолчанию
  - data:
      should_show: false
      can_skip: false
      can_postpone: false
      skip_release_delay_hours: 2160       # 90 дней
      skip_all_releases_delay_hours: 72
      postpone_release_delay_hours: 96
      postpone_all_releases_delay_hours: 24

  # Unsupported — блокирующее обновление
  - when: { app_status_is: unsupported }
    data:
      should_show: true
      can_skip: false
      can_postpone: false

  # Deprecated — можно отложить ненадолго
  - when: { app_status_is: deprecated }
    data:
      should_show: true
      can_postpone: true
      postpone_release_delay_hours: 24

  # Active/Outdated — полная свобода
  - when: { app_status_is: [active, outdated] }
    data:
      should_show: true
      can_skip: true
      can_postpone: true

  # Точечное включение по таргетам
  - when:
      app_status_is: outdated
      view_target_is: [card, toast, aboutScreen]
    data:
      should_show: true
```

## App Settings Rules — жизненный цикл версий

```yaml
app_settings:
  # По умолчанию все активные
  - data:
      app_status: active

  # Автоматический lifecycle от даты нового релиза
  - when: { app_version_is: any }
    rollout:
      date: $updateReleaseDate
      delay_hours: 48              # 2 дня → outdated
      gradual_rollout_hours: 72
    data:
      app_status: outdated

  # Lifecycle от даты текущей версии
  - when: { app_version_is: any }
    rollout:
      date: $localReleaseDate
      delay_hours: 2880            # 120 дней → deprecated
      gradual_rollout_hours: 168
    data:
      app_status: deprecated

  - when: { app_version_is: any }
    rollout:
      date: $localReleaseDate
      delay_hours: 6760            # 280 дней → unsupported
    data:
      app_status: unsupported

  # Версионные ограничения (semver)
  - when: { app_version_is: ["<=5.1.0 >=4.2.0", "<4.0.0"] }
    data:
      app_status: deprecated

  # Контролируемая раскатка
  - when: { app_version_is: "<=3.0.0" }
    rollout:
      date: "2024-01-01"
      delay_hours: 12
      gradual_rollout_hours: 72
      user_segmentation_percent: 10    # Сначала 10% пользователей
    data:
      app_status: unsupported
```

## Sources — источники дистрибуции

```yaml
sources:
  - name: appStore
    platforms: [ios, macos]
    content:
      - data:
          update_url: "https://apps.apple.com/app/id123"

  - name: googlePlay
    platforms: [android]
    content:
      - data:
          update_url: "https://play.google.com/store/apps/details?id=$appPackageName"

  - name: ruStore
    platforms: [android]
    content:
      - data:
          update_url: "https://apps.rustore.ru/app/$appPackageName"
      - when: { locale_is: ru }
        data:
          update_button: "Перейти в RuStore"

  - name: github
    platforms: [android, windows, macos, linux]
    content:
      - data:
          update_url: "https://github.com/user/repo/releases"
      # Platform-specific URL
      - when: { platform_is: windows }
        data:
          update_url: "https://github.com/user/repo/releases/download/v$releaseVersion/setup.exe"
```

Платформы можно указывать с переопределениями:

```yaml
sources:
  - name: github
    platforms:
      - windows
      - linux
      - name: android
        content:
          - data:
              update_url: "https://github.com/user/repo/releases/download/v$releaseVersion/app.apk"
```

## Releases — релизы

```yaml
releases:
  # Простой релиз
  - version: "2.1.0"
    date: "2024-08-24 15:35:00"
    content:
      - data:
          release_notes: "Улучшения и исправления"
    sources: [googlePlay, appStore]

  # Локализованный релиз
  - version: "2.0.0"
    date: "2024-08-20 12:00:00"
    content:
      - data:
          release_notes: "Major update with new features"
      - when: { locale_is: ru }
        data:
          release_notes: "Крупное обновление с новыми возможностями"
    sources: [googlePlay, appStore]

  # Релиз с переопределениями для источника
  - version: "1.2.0"
    date: "2024-08-15 10:00:00"
    sources:
      - googlePlay
      - appStore
      - name: ruStore
        platforms: [android]
        release_override:
          version: "1.2.1"           # Другая версия в RuStore
        content:
          - when: { locale_is: ru }
            data:
              title: "Обновление RuStore"
      - name: github
        platforms:
          - linux
          - name: windows
            content:
              - data:
                  update_url: "https://github.com/user/repo/releases/download/v1.2.0/setup.exe"
            settings:
              - when: { app_status_is: deprecated }
                data: { can_postpone: true }

  # Beta-релиз с ограниченным доступом
  - version: "2.1.0-beta.1"
    date: "2024-09-01 10:00:00"
    content:
      - when:
          custom_params:
            user_tier_is: [beta, internal]
        data:
          title: "Beta Update"
          release_notes: "Beta features for testing"
    settings:
      - data: { should_show: false }
      - when:
          custom_params:
            user_tier_is: [beta, internal]
        rollout:
          gradual_rollout_hours: 48
        data: { should_show: true }
    sources: [googlePlay]
```

## Правила мерджа и приоритеты

1. **Порядок в списке важен**: правила применяются последовательно, поздние переопределяют ранние
2. **Специфичность контекста**: `release` > `source` > `platform` > глобальные правила
3. **Объединение полей**: поля мерджатся по ключам, отсутствующие не затираются

```yaml
content:
  # Правило 1 (базовое)
  - data:
      title: "Update"
      description: "New version"
      
  # Правило 2 (переопределяет только title)
  - when: { locale_is: ru }
    data:
      title: "Обновление"
      # description остается "New version"
```

## Custom Params — разделение по назначению

```yaml
content:
  - when:
      custom_params:
        env_is: prod              # Условие (суффикс _is)
        user_tier_is: premium     # Условие
    data:
      title: "Premium Update"
      custom_params:
        analytics_track: "event"  # Данные для приложения
        ui_variant: "gold"        # Данные для приложения
```

## Лучшие практики

1. **Жизненный цикл**: постепенно повышайте срочность `active` → `outdated` → `deprecated` → `unsupported`
2. **UX**: по умолчанию `should_show: false`, явно включайте нужные таргеты
3. **Раскатка**: для критических изменений используйте `delay_hours` + `gradual_rollout_hours` + `user_segmentation_percent`
4. **Локализация**: базовый контент без `when`, локализации через `when: { locale_is: ... }`
5. **Простота**: используйте короткий синтаксис где возможно: `- when: { locale_is: ru }`
