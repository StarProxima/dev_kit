
## 1.4.0
* Рефакторинг `RateLimiter`
* Параметр `includeRequestTime` в `Throttle` заменён на enum `cooldownLaunch`, в `Debounce` - на `shouldCancelRunningOperations` для предоставления более понятного и очевидного API.
* Добавлены параметры `cooldownTickDelay`, `onTickCooldown`, `onStartCooldown`, `onEndCooldown` в `Throttle` для возможности обработки кулдауна в приложении.

## 1.3.0
* Ренейминг `ErrorReponse` -> `ApiError`.
* Добавлен `ErrorType` в `ApiError`, позволяющий использовать кастомные классы ошибок, специфичных для приложения или бэкенда.

## 1.2.1
* Исправление и рефакторинг метода `setError` в `SingleValidatorBase`

## 1.2.0
* Добавлен параметр `errorVisibility` в `ApiWrap`

## 1.1.0
* Добавлен параметр `executeIf` в `ApiWrap`

## 1.0.0
* Initial version
* Добавлен `ApiWrap`, позволяющий более удобно и безопасно работать с любым API, предоставляя методы для обработки разных результатов функций с автоматической или ручной обработкой ошибок.
* Добавлен `RateLimiter` в `ApiWrap`, позволяющий бесшовно реализовать `Debounce` и `Throttle` для любых функций.
* Добавлен `Retry` в `ApiWrap`, позволяющий возможности при ошибке отправлять запросы повторно через регулируемое время.
* Добавлены `SingleValidator` и `AsyncSingleValidator`, которые с помощью `Riverpod` выполняют всю работу по управлению состоянием и предоставляют методы, позволяющие реализовать различные типы валидации.
* Добавлен `PersistenceMixin`, позволяющий сохранять состояние `Notifier` при выходе из приложения
* Добавлено расширение `AsyncUtils`, предоставляющий методы для более удобного управления асинхронным состоянием в `AsyncNotifier`.
* Добавлены виджеты `AutoUnfocus`, `SliverBottomAlign` и `ToastCard`.