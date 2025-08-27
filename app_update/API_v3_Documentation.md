## App Update API v3 — README

App Update — система конфигураций для управления обновлениями приложения на разных платформах и в разных сторах. Поддерживает правила контента, поведение UI, жизненный цикл версий, прогрессивный выкатывание и мульти‑источники дистрибуции.

## Быстрый старт

Минимальная конфигурация, чтобы показать карточку обновления для любых версий и локалей:

```yaml
content:
  - view_target_is: card
    app_status_is: any
    locale_is: any
    data:
      title: Обновление доступно
      description: Новая версия с улучшениями

settings:
  - app_status_is: any
    view_target_is: any
    data:
      should_show: true

app_settings:
  - version: any
    data:
      app_status: active
```

Добавьте простейший источник и релиз:

```yaml
sources:
  - name: appStore
    url: https://apps.apple.com/app/id123
    platforms: [ios]

releases:
  - version: 1.2.0
    date: "2024-08-24 15:35:00"
    content:
      release_notes: Улучшения и исправления
    sources: [appStore]
```

## Структура конфигурации

Конфиг состоит из разделов:

```yaml
content:    # Текст/контент для UI по контекстам
settings:   # Поведение UI и доступные действия
app_settings: # Жизненный цикл версий (статусы, выкатывание)
source_is:          # Источники дистрибуции (сторы/платформы)
releases:         # Конкретные релизы приложения
```

## Базовые понятия

- **Статусы приложения (`app_statuses`)**: `active`, `updateable`, `outdated`, `deprecated`, `unsupported`, `any`.
- **Таргеты отображения (`view_targets`)**: `card`, `dialog`, `screen`, `toast`, `profileBadge`, `aboutScreen`, `any`.
- **Локали (`locales`)**: коды языков, например `ru`, `en`, либо `any`.
- **Дата и время (`date`)**: локальное время в формате `YYYY-MM-DD HH:mm:ss` либо UTC c суффиксом `Z`.
- **Динамические даты**: `$localReleaseDate` (дата текущей версии приложения) и `$updateReleaseDate` (дата последнего доступного обновления).
- **Выкатывание**: `delay_hours`, `rollout_hours`, `segmentation_percent`.

## Content Rules — контент UI

Определяют, что отображать пользователю в разных контекстах. Несколько правил могут примениться к одному контексту; последние по списку имеют приоритет и переопределяют поля в `data`.

Пример: общий заголовок для карточки и отдельный — для RU во время старых версий:

```yaml
content:
  - view_target_is: card
    app_status_is: any
    locale_is: any
    data:
      title: Обновите приложение
      description: Описание

  - view_target_is: any
    locale_is: ru
    app_status_is: [outdated, deprecated]
    data:
      title: Обновите приложение (важно)
```

Поддерживаются произвольные поля в `data`, например:

```yaml
data:
  custom_img:
    url: https://example.com
    border_radius: 10
```

## Settings Rules — поведение UI

Определяют, можно ли показывать UI и какие действия доступны пользователю. Работают по тем же правилам мерджа.

Рекомендуемая матрица действий по статусам:

```yaml
settings:
  # База: по умолчанию скрыто, явно включаем нужные места
  - app_status_is: any
    view_target_is: any
    data:
      should_show: false
      can_skip: false
      skip_release_delay_hours: 2160   # 90 дней
      skip_any_releases_delay_hours: 72
      can_postpone: false
      postpone_release_delay_hours: 96
      postpone_any_releases_delay_hours: 24

  # Unsupported — блокирующее обновление
  - app_status_is: unsupported
    view_target_is: any
    data:
      can_skip: false
      can_postpone: false

  # Deprecated — разрешаем отложить на короткий срок
  - app_status_is: deprecated
    view_target_is: any
    data:
      can_postpone: true
      postpone_release_delay_hours: 24
      postpone_any_releases_delay_hours: 24

  # Optional — полная свобода
  - app_status_is: [outdated, updateable, active]
    view_target_is: any
    data:
      can_skip: true
      can_postpone: true

  # Точечное включение UI по таргетам
  - app_status_is: active
    view_target_is: aboutScreen
    data:
      should_show: true

  - app_status_is: updateable
    view_target_is: [aboutScreen, card]
    data:
      should_show: true

  - app_status_is: outdated
    view_target_is: [aboutScreen, card, profileBadge, toast]
    data:
      should_show: true

  - app_status_is: deprecated
    view_target_is: [aboutScreen, card, profileBadge, screen]
    data:
      should_show: true

  - app_status_is: unsupported
    view_target_is: screen
    data:
      should_show: true
```

## App Status Rules — жизненный цикл версий

Классифицируют версии по статусам, учитывая дату активации, динамические ссылки на даты и фазный rollout.

База и динамические даты:

```yaml
app_settings:
  - app_status: active

  # Берём дату последнего доступного обновления
  - app_version_is: any
    date: $updateReleaseDate
    data:
     app_status: active

  - date: $updateReleaseDate
    delay_hours: 48
    rollout_hours: 72
    data:
      app_status: outdated

  # Жизненный цикл от локальной даты релиза текущего приложения
  - date: $localReleaseDate
    delay_hours: 168
    rollout_hours: 72
    data:
      app_status: outdated
  - date: $localReleaseDate
    delay_hours: 2880
    rollout_hours: 168
    data:
      app_status: deprecated
  - date: $localReleaseDate
    delay_hours: 6760
    rollout_hours: 168
    data:
      app_status: unsupported
```

Ограничения по версиям (semver):

```yaml
app_settings:
  - version: ["<=5.1.0 >=4.2.0", ">5.6.0 <5.6.7"]
    data:
      app_status: deprecated

  - version: "<4.0.0"
    date: 2014-10-17 00:00:00
    delay_hours: 168
    rollout_hours: 72
    data: { app_status: outdated }

  - version: "<4.0.0"
    date: 2014-10-17 00:00:00
    delay_hours: 2880
    rollout_hours: 168
    data: { app_status: deprecated }

  - version: "<4.0.0"
    date: 2015-01-01 00:00:00
    delay_hours: 6720
    rollout_hours: 336

  - version: "<=2.0.0"
    date: 2014-10-17 23:00:00
    source_is:
      - GooglePlay
      - name: AppStore
        platforms: [ios]
    data: { app_status: unsupported }

  - version: ">=6.0.0"
    data: { app_status: active }

  # Пример фазного выкатывания
  - version: "<=3.0.0"
    date: 2014-10-17
    delay_hours: 12
    rollout_hours: 72
    segmentation_percent: 10
    data: { app_status: unsupported }

  - version: "<=3.0.0"
    date: 2014-10-17
    delay_hours: 120
    rollout_hours: 72
    segmentation_percent: 50
    data: { app_status: unsupported }
```

## Sources — источники дистрибуции

Задают сторы/каналы и платформы, на которые распространяется релиз. Возможны переопределения на уровне платформ и контента.

```yaml
sources:
  - name: appStore
    url: https://example.com
    platforms: [macos, { name: ios }]

  - name: appGallery
    url: https://example.com
    content:
      - locale_is: ru
        data: { update_button: Перейти в AppGallery }
      - locale_is: en
        data: { update_button: Go to AppGallery }

  - name: ruStore
    url: https://example.com

  - name: gitHub
    url: https://example.com
    platforms:
      - name: android
        source:
          url: https://example.com/android
          content:
            title: Title
      - windows
      - macos
      - linux

  - name: site
    platforms: [android]
    url: https://example.com
```

## Releases — релизы

Описывают конкретные версии, их даты и привязку к источникам, включая локализацию контента и переопределения по платформам.

```yaml
releases:
  - version: 0.3.7
    date: "2024-08-24 15:35:00"   # локальное время
    content:
      release_notes: |-
        # Big update!
        [click](https://example.com) - full changelog.
        ### Short notes
        - Added bugs
        - Fixed features
    sources: [googlePlay, appStore, ruStore, { name: github, source: { url: https://example.com, platforms: [android, ios, aurora]}}]

  - version: 0.3.8+10-beta
    content: { release_notes: Minor Improvements }
    sources: []
    is_super_ultra_mega_release: true   # произвольные поля поддерживаются

  - version: 0.0.3+80
    content:
      - locale_is: ru
        data: { release_notes: Improvements }
      - locale_is: en
        data: { release_notes: Improvements }
    sources:
      - name: googlePlay
        release:
          date: 2014-10-17 23:00:00

  - version: 1.2.0
    content: { release_notes: Improvements }
    sources:
      - appStore
      - name: googlePlay
      - name: ruStore
        url: www.example.com
        platforms: [android]
        release:
          version: 1.2.1
          content: { title: RuStore Title }
      - name: github
        url: https://github.com/hiddify/hiddify-next/releases/
        release:
          date: 2014-10-20 12:00:00
        platforms:
          - macos
          - linux
          - name: windows
            source:
              url: https://github.com/hiddify/hiddify-next/releases/download/v0.14.0/hiddify-windows-x64-setup.zip
              release:
                content:
                  - locale_is: ru
                    data: { release_notes: Windows Github release notes }
                settings:
                  can_postpone: true

  - version: 0.2.4
    # UTC
    date: 2014-10-17 23:00:00Z
    content:
      title: Title
      description: Description
      release_notes: Note
    settings:
      can_skip: true
      can_postpone: true
    sources:
      - name: googlePlay
        url: www.example.com
        release:
          date: 2014-10-17 23:00:00
          settings: { can_postpone: true }
        platforms:
          - name: android
            source:
              release:
                settings:
                  - target: dialog
                    app_status_is: outdated
                    data: { can_skip: true, can_postpone: true }

      - name: appStore
        content: { release_notes: note ios }
        date: 2014-10-18 23:00:00
```

## Правила мерджа и приоритеты

- **Порядок в списке важен**: более позднее правило переопределяет предыдущие поля в `data`/`settings`.
- **Чем контекст специфичнее — тем приоритетнее**: переопределения на уровне `release` > `source` > глобальных `content_rules`/`settings_rules`.
- **Вложенность источников**: `platform.source.release` переопределяет `source.release`, который переопределяет `release`.
- **Объединение**: поля объединяются по ключам; отсутствующие поля не затираются.

## Лучшие практики

- **Жизненный цикл версий**: постепенно повышайте срочность — `updateable` → `outdated` → `deprecated` → `unsupported` с использованием `$localReleaseDate`/`$updateReleaseDate`.
- **UX**: по умолчанию `should_show: false`, явно включайте нужные таргеты; давайте пользователю выбор для не‑критичных апдейтов.
- **Мульти‑платформенность**: используйте `platforms` и точечные переопределения для разных ОС.
- **Прозрачность**: локализуйте контент (`locales`) и ведите понятные `release_notes`.