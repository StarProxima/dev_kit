# App Update API v4 — Enhanced Rule Structure

App Update — система конфигураций для управления отображением обновлений приложения на разных платформах и в разных сторах. Версия v4 представляет **значительно улучшенную структуру правил** с четким разделением концепций.

## 🎯 Ключевые улучшения v4

### Семантическая структура правил
```yaml
# v4 - Crystal Clear Structure:
content:
  - when:                    # 🎯 Условия применения
      view_target_is: card
      app_status_is: outdated
      locale_is: ru
    rollout:                 # ⏰ Параметры раскатки
      date: $updateReleaseDate
      delay_hours: 24
      rollout_hours: 168
      segmentation_percent: 25
    data:                    # 📄 Данные для UI
      title: "Обновление доступно"
      description: "Версия $releaseVersion готова"
```

### Разделение custom_params по назначению
```yaml
content:
  - when:
      custom_params:
        env_is: prod              # ← Для матчинга условий
        user_tier_is: premium     # ← Логика применения правила
    data:
      custom_params:
        analytics_track: "event"  # ← Данные для результата
        ui_variant: "premium"     # ← Данные для приложения
```

## Быстрый старт v4

### Минимальная конфигурация
```yaml
content:
  - data:
      title: "Обновление доступно"
      description: "Новая версия с улучшениями"

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
      release_notes: "Улучшения и исправления"
    sources: [appStore]
```

### Локализованная конфигурация
```yaml
content:
  # Базовый контент
  - data:
      title: "Update Available"
      description: "Version $releaseVersion is available"
      
  # Русская локализация
  - when: { locale_is: ru }
    data:
      title: "Обновление доступно"
      description: "Версия $releaseVersion готова к установке"
```

### Controlled Rollout
```yaml
app_settings:
  # Базовый статус
  - data:
      app_status: active
      
  # Постепенная смена статуса на outdated
  - when:
      app_version_is: "<2.0.0"
    rollout:
      date: $updateReleaseDate
      delay_hours: 48              # 2 дня после релиза
      rollout_hours: 168           # Раскатка за неделю
      segmentation_percent: 30     # 30% пользователей
    data:
      app_status: outdated
```

## Структура конфигурации v4

### Основные секции
```yaml
content:      # Контент для UI по условиям
settings:     # Поведение UI и доступные действия
app_settings: # Жизненный цикл версий (статусы, раскатка)
sources:      # Источники дистрибуции (сторы/платформы)
releases:     # Конкретные релизы приложения
```

### Структура правил
Каждое правило состоит из трех логических секций:

#### 1. when (Условия применения)
Определяет **когда** правило должно применяться:
```yaml
when:
  view_target_is: [card, dialog]      # UI таргет
  app_status_is: outdated             # Статус версии
  locale_is: ru                       # Локаль пользователя
  platform_is: android               # Платформа
  source_is: googlePlay               # Источник установки
  app_version_is: ">=1.0.0 <2.0.0"   # Версионные ограничения
  custom_params:                      # Кастомные условия
    env_is: prod
    user_tier_is: premium
```

#### 2. rollout (Управление раскаткой)
Определяет **как и когда** раскатывать правило:
```yaml
rollout:
  date: $updateReleaseDate            # Базовая дата
  delay_hours: 24                     # Задержка активации
  rollout_hours: 168                  # Длительность раскатки
  segmentation_percent: 25            # Процент пользователей
```

#### 3. data (Данные правила)
Определяет **что** показать/применить:
```yaml
data:
  title: "Заголовок"
  description: "Описание"
  custom_params:                      # Данные для приложения
    analytics_track: "event_name"
    ui_theme: "dark"
```

## Базовые понятия v4

### Условия (when секция)
- **view_target_is**: `card`, `dialog`, `screen`, `toast`, `aboutScreen`, `any`
- **app_status_is**: `active`, `outdated`, `deprecated`, `unsupported`, `any`
- **locale_is**: коды языков (`ru`, `en`) или `any`
- **platform_is**: `android`, `ios`, `macos`, `windows`, `linux`, `web`, `any`
- **source_is**: источники (`googlePlay`, `appStore`, `ruStore`, `gitHub`) или кастомные
- **app_version_is**: semver ограничения (`">=1.0.0 <2.0.0"`, `">2.1.0"`)
- **custom_params**: произвольные поля с суффиксом `_is` для матчинга

### Раскатка (rollout секция)
- **date**: статическая дата (`"2024-01-01 10:00:00"`) или динамическая (`$localReleaseDate`, `$updateReleaseDate`)
- **delay_hours**: задержка активации правила (в часах)
- **rollout_hours**: длительность постепенной раскатки (в часах)
- **segmentation_percent**: процент пользователей (0-100) для A/B тестирования

### Данные (data секция)
- **content rules**: `title`, `description`, `updateButton`, `skipButton`, `postponeButton`, `releaseNotes`
- **settings rules**: `shouldShow`, `canSkip`, `canPostpone`, delay параметры
- **app_settings rules**: `appStatus`
- **custom_params**: произвольные данные для приложения (без суффикса `_is`)

## Content Rules v4 — контент UI

### Базовая локализация
```yaml
content:
  # Английский (по умолчанию)
  - data:
      title: "Update $appName"
      description: "Version $releaseVersion available"
      updateButton: "Update"
      skipButton: "Skip"
      postponeButton: "Later"
      
  # Русская локализация
  - when: { locale_is: ru }
    data:
      title: "Обновите $appName"
      description: "Версия $releaseVersion доступна"
      updateButton: "Обновить"
      skipButton: "Пропустить"
      postponeButton: "Позже"
```

### Статус-специфичный контент
```yaml
content:
  # Базовый контент
  - data:
      title: "Update Available"
      description: "New version available"
      
  # Критические обновления
  - when: { app_status_is: unsupported }
    data:
      title: "Critical Update Required"
      description: "Your version is no longer supported"
      
  # Deprecated версии на русском
  - when:
      app_status_is: deprecated
      locale_is: ru
    data:
      title: "Важное обновление"
      description: "Ваша версия устарела, обновитесь как можно скорее"
```

### Платформо-специфичный контент
```yaml
content:
  # Базовый контент
  - data:
      title: "Update $appName"
      updateButton: "Update"
      
  # iOS специфичный
  - when: { platform_is: ios }
    data:
      title: "Update $appName via App Store"
      updateButton: "Open App Store"
      
  # Android Google Play
  - when:
      platform_is: android
      source_is: googlePlay
    data:
      title: "Update $appName via Play Store"
      updateButton: "Open Play Store"
      
  # Android RuStore русская локализация
  - when:
      platform_is: android
      source_is: ruStore
      locale_is: ru
    data:
      title: "Обновление $appName в RuStore"
      updateButton: "Открыть RuStore"
```

## Settings Rules v4 — поведение UI

### Базовая матрица поведения
```yaml
settings:
  # Консервативные настройки по умолчанию
  - data:
      should_show: false           # Скрыто по умолчанию
      can_skip: false
      can_postpone: false
      skip_release_delay_hours: 2160
      skip_all_releases_delay_hours: 72
      postpone_release_delay_hours: 96
      postpone_all_releases_delay_hours: 24

  # Критические обновления - строгие правила
  - when: { app_status_is: unsupported }
    data:
      should_show: true
      can_skip: false              # Нельзя пропустить
      can_postpone: false          # Нельзя отложить

  # Deprecated - ограниченная свобода
  - when: { app_status_is: deprecated }
    data:
      should_show: true
      can_skip: false
      can_postpone: true
      postpone_release_delay_hours: 24  # Короткая отсрочка

  # Обычные обновления - полная свобода
  - when: { app_status_is: [active, outdated] }
    data:
      should_show: true
      can_skip: true
      can_postpone: true
```

### UI таргет специфичные настройки
```yaml
settings:
  # About screen - всегда показываем информацию
  - when:
      view_target_is: aboutScreen
      app_status_is: [active, outdated, deprecated]
    data:
      should_show: true
      
  # Карточки и уведомления - только для устаревших
  - when:
      view_target_is: [card, toast]
      app_status_is: [outdated, deprecated]
    data:
      should_show: true
      
  # Полноэкранный режим - только критические
  - when:
      view_target_is: screen
      app_status_is: unsupported
    data:
      should_show: true
      can_skip: false
      can_postpone: false
```

## App Settings Rules v4 — жизненный цикл

### Базовый lifecycle управление
```yaml
app_settings:
  # По умолчанию все активные
  - data:
      app_status: active

  # Automatic aging от даты текущей версии
  - when: { app_version_is: any }
    rollout:
      date: $localReleaseDate
      delay_hours: 168             # 1 неделя → outdated
    data:
      app_status: outdated
      
  - when: { app_version_is: any }
    rollout:
      date: $localReleaseDate
      delay_hours: 2160            # 90 дней → deprecated
    data:
      app_status: deprecated
      
  - when: { app_version_is: any }
    rollout:
      date: $localReleaseDate
      delay_hours: 4320            # 180 дней → unsupported
    data:
      app_status: unsupported
```

### Версионные ограничения
```yaml
app_settings:
  # Specific версии deprecated
  - when: { app_version_is: ["<=5.1.0 >=4.2.0", ">5.6.0 <5.6.7"] }
    data:
      app_status: deprecated
      
  # Старые версии с temporal lifecycle
  - when: { app_version_is: "<4.0.0" }
    rollout:
      date: "2014-10-17 00:00:00"
      delay_hours: 168
    data:
      app_status: outdated
      
  - when: { app_version_is: "<4.0.0" }
    rollout:
      date: "2014-10-17 00:00:00"
      delay_hours: 2880
    data:
      app_status: deprecated
```

### Controlled Rollout Examples
```yaml
app_settings:
  # Осторожная раскатка критического статуса
  - when:
      app_version_is: "<=3.0.0"
      custom_params:
        env_is: [prod, staging]
    rollout:
      date: "2014-10-17 00:00:00"
      delay_hours: 12              # 12 часов задержки
      rollout_hours: 72            # 3 дня раскатки
      segmentation_percent: 10     # Только 10% пользователей первоначально
    data:
      app_status: unsupported
      
  # Расширение до 50% пользователей
  - when: { app_version_is: "<=3.0.0" }
    rollout:
      date: "2014-10-17 00:00:00"
      delay_hours: 120             # 5 дней задержки
      rollout_hours: 72
      segmentation_percent: 50     # 50% пользователей
    data:
      app_status: unsupported
```

## Sources v4 — источники дистрибуции

### Базовые источники
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
      - when: { locale_is: ru }
        data:
          update_url: "https://apps.rustore.ru/app/$appPackageName"
          updateButton: "Перейти в RuStore"
```

### Сложные источники с переопределениями
```yaml
sources:
  - name: github
    platforms:
      - android
      - ios  
      - windows
      - macos
      - linux
    content:
      - data:
          update_url: "https://github.com/user/repo/releases"
          
      # Platform-specific URLs:
      - when: { platform_is: windows }
        data:
          update_url: "https://github.com/user/repo/releases/download/v$releaseVersion/setup.exe"
          
      # Локализация для русских пользователей
      - when:
          platform_is: android
          locale_is: ru
        data:
          update_url: "https://github.com/user/repo/releases/download/v$releaseVersion/app.apk"
          updateButton: "Скачать APK"
```

## Releases v4 — релизы

### Простые релизы
```yaml
releases:
  - version: "2.1.0"
    date: "2024-08-24 15:35:00"
    content:
      - data:
          release_notes: "Улучшения производительности и исправления ошибок"
    sources: [googlePlay, appStore]
```

### Комплексные релизы с overrides
```yaml
releases:
  - version: "2.0.0"
    date: "2024-08-24 15:35:00"
    content:
      # Базовые release notes
      - data:
          release_notes: "Major update with new features"
          
      # Русская локализация
      - when: { locale_is: ru }
        data:
          release_notes: "Крупное обновление с новыми возможностями"
          
    sources:
      - googlePlay
      - appStore
      
      # RuStore с особенностями
      - name: ruStore
        platforms: [android]
        release_override:
          version: "2.0.1"           # Другая версия в RuStore
        content:
          - when: { locale_is: ru }
            data:
              title: "Обновление RuStore"
              release_notes: "Версия для российского магазина"
              
      # GitHub с platform overrides
      - name: github
        platforms:
          - windows
          - linux
          - name: macos
            content:
              - data:
                  update_url: "https://github.com/user/repo/releases/download/v2.0.0/macos.dmg"
            settings:
              - when: { app_status_is: deprecated }
                data: { can_postpone: true }
```

### Beta релизы с controlled access
```yaml
releases:
  - version: "2.1.0-beta.1"
    date: "2024-08-20 10:00:00"
    content:
      - when:
          custom_params:
            user_tier_is: [beta, internal]
        data:
          title: "Beta Update Available"
          description: "Help us test new features"
          release_notes: "Beta features for testing"
    settings:
      # Скрыто по умолчанию
      - data: { should_show: false }
      
      # Показываем только beta users с rollout
      - when:
          custom_params:
            user_tier_is: [beta, internal]
        rollout:
          date: "2024-08-20 10:00:00"
          delay_hours: 0
          rollout_hours: 48          # 2 дня постепенной раскатки
          segmentation_percent: 100  # Всем eligible users
        data: { should_show: true }
    sources: [googlePlay, appStore]
```

## Правила мерджа и приоритеты v4

### Последовательное применение правил
```yaml
content:
  # Правило 1 (базовое)
  - data:
      title: "Update Available"
      description: "New version"
      updateButton: "Update"
      
  # Правило 2 (русская локализация)
  - when: { locale_is: ru }
    data:
      title: "Обновление доступно"      # ← Переопределяет title
      description: "Новая версия"       # ← Переопределяет description
      # updateButton остается "Update"
      
  # Правило 3 (критический статус)
  - when:
      app_status_is: deprecated
      locale_is: ru
    data:
      title: "Важное обновление"        # ← Финальное переопределение
      # description и updateButton остаются из предыдущих правил
```

### Custom Params Merging
```yaml
# Rule merging для custom_params:
content:
  # Rule 1
  - data:
      custom_params:
        theme: "light"
        version: "1.0"
        
  # Rule 2 (добавляет и переопределяет)
  - when: { locale_is: ru }
    data:
      custom_params:
        theme: "dark"               # ← Переопределяет
        locale_variant: "ru"        # ← Добавляет новое поле
        # version остается "1.0"

# Final result custom_params:
# { theme: "dark", version: "1.0", locale_variant: "ru" }
```

## Advanced Patterns v4

### Multi-Stage Rollout
```yaml
app_settings:
  # Phase 1: Alpha users (5%) немедленно
  - when:
      custom_params:
        user_tier_is: alpha
    rollout:
      date: $updateReleaseDate
      delay_hours: 0
      segmentation_percent: 5
    data:
      app_status: outdated
      
  # Phase 2: Beta users (25%) через сутки
  - when:
      custom_params:
        user_tier_is: [alpha, beta]
    rollout:
      date: $updateReleaseDate
      delay_hours: 24
      segmentation_percent: 25
    data:
      app_status: outdated
      
  # Phase 3: All users (100%) через неделю
  - when: { app_version_is: any }
    rollout:
      date: $updateReleaseDate
      delay_hours: 168
    data:
      app_status: outdated
```

### Feature Flag Integration
```yaml
content:
  # Новая функция только для premium пользователей
  - when:
      custom_params:
        feature_flag_is: new_ui_v2
        user_tier_is: [premium, enterprise]
    rollout:
      date: "2024-09-01 00:00:00"
      delay_hours: 0
      rollout_hours: 168
      segmentation_percent: 50     # A/B test на 50%
    data:
      title: "New UI Available"
      description: "Experience our redesigned interface"
      custom_params:
        feature_variant: "ui_v2"
        analytics_track: "new_ui_rollout"
```

### Emergency Updates
```yaml
app_settings:
  # Emergency hotfix deployment
  - when:
      app_version_is: ["1.2.0", "1.2.1"]  # Affected versions
      custom_params:
        env_is: [prod, staging]
    rollout:
      date: "2024-08-25 14:30:00"         # Emergency deployment time
      delay_hours: 0                      # Immediate
      segmentation_percent: 100           # All affected users
    data:
      app_status: unsupported

settings:
  - when: { app_status_is: unsupported }
    data:
      should_show: true
      can_skip: false                     # Must update
      can_postpone: false
```

## Лучшие практики v4

### 1. Структурная организация
```yaml
# ✅ Good - логическая группировка секций:
content:
  - when:                    # Группируйте условия логически
      view_target_is: card
      app_status_is: outdated
      locale_is: ru
    rollout:                 # Все temporal параметры вместе
      date: $updateReleaseDate
      delay_hours: 24
      rollout_hours: 168
    data:                    # Все данные результата вместе
      title: "Обновление"
      description: "Доступно"
```

### 2. Custom Params Best Practices
```yaml
# ✅ Good - четкое разделение назначения:
content:
  - when:
      custom_params:
        env_is: prod              # ← Matching: суффикс _is
        user_type_is: premium     # ← Matching: суффикс _is
    data:
      custom_params:
        analytics_track: "event"  # ← Data: без суффикса _is
        ui_variant: "premium"     # ← Data: без суффикса _is
```

### 3. Rollout Safety
```yaml
# ✅ Good - безопасная раскатка критических изменений:
app_settings:
  - when: { app_version_is: "<1.0.0" }
    rollout:
      date: $updateReleaseDate
      delay_hours: 24              # Дайте время на stabilization
      rollout_hours: 168           # Постепенно за неделю
      segmentation_percent: 20     # Начните с малой группы
    data:
      app_status: unsupported
```

### 4. Progressive Complexity
```yaml
# ✅ Good - используйте minimal syntax для простых случаев:
content:
  # Simple:
  - when: { locale_is: ru }
    data: { title: "Заголовок" }
    
  # Medium:
  - when:
      app_status_is: outdated
      locale_is: ru
    data:
      title: "Рекомендуемое обновление"
      
  # Complex (only when needed):
  - when:
      view_target_is: card
      app_status_is: [outdated, deprecated]
      locale_is: ru
      platform_is: android
    rollout:
      date: $updateReleaseDate
      delay_hours: 48
      rollout_hours: 168
      segmentation_percent: 30
    data:
      title: "Важное обновление Android"
      description: "Обновитесь через Google Play"
```

## Migration from v3 to v4

### Automatic Conversion Rules
```yaml
# v3 structure:
content:
  - view_target_is: card
    app_status_is: any
    date: 2020-01-01
    delay_hours: 24
    data:
      title: "Title"

# v4 equivalent:
content:
  - when:
      view_target_is: card
      app_status_is: any
    rollout:
      date: 2020-01-01
      delay_hours: 24
    data:
      title: "Title"
```

### Custom Params Migration
```yaml
# v3 confusing custom_params:
content:
  - custom_params:
      env_is: prod              # Matching
      analytics: data           # Data storage
    data: { title: "Title" }

# v4 clear separation:
content:
  - when:
      custom_params:
        env_is: prod            # ← Clearly matching
    data:
      title: "Title"
      custom_params:
        analytics: data         # ← Clearly data storage
```

**API v4 представляет significant evolution в configuration design, обеспечивая excellent developer experience с maintained powerful functionality.**
