## 1.14.3 - 30.08.2024
* Добавлен `AuthToken` для представления токена пользователя
* Добавлен `AuthTokenHandler` для обработки токена авторизации `AuthToken` пользователя
* Переименован `TokenStorage` в `SecurityTokenStorage`

## 1.14.0 - 04.2024
* `RateLimiter` добавлен в `Sctrict` методы `ApiWrap`
* Теперь вместо вызова onCancelOperation в `RateLimiter`, будет вызываться `onError` c `RateCancelError`
* Добавлены параметры `delayTickInterval`, `onDelayTick`, `onDelayStart`, `onDelayEnd` в `Debounce`
* Добавлены тесты для `ApiWrap`, `Retry` и `RateLimiter`

## 1.13.0 - 04.2024
* Добавлен метод `selectData` к `AsycnValue`, который похож на `AsyncValue.whenData`, но позволяет выбирать часть из состояния провайдера, поддерживая skipLoadingOnReload, skipLoadingOnRefresh и skipError
* Исправлена ошибка, связанная с использованием `AsyncValue.whenData` в `AsyncBuilder.paginated`

## 1.12.0 - 04.2024
* В `AsyncBuilder.paginated` добавлена функция для возможности кастомизируемой отложенной анимации для элементов списка с помощью одного `AnimationController`. Добавлен `ItemAnimationSettings` с параметрами для настройки анимации

## 1.11.0 - 04.2024
* Добавлены хуки `useAppLifecycleListener` и `useListener`

## 1.10.0 - 03.2024
* Исправлена обработка `ErrorType` в `Retry`, добавлен парамерт `minDelay`
* Исправлено взаимодействие `RateLimiter` и `Retry`

## 1.9.0 - 02.2024
* Добавлен `AsyncBuilder` - виджет для упрощения работы с асинхронными данными, предоставляет билдеры по умолчанию для обработки состояний загрузки и обработки ошибок
* Добавлен `AsyncBuilder.paginated` - функция для организации пагинации списков с дополнительным функционалом, помогает управлять загрузкой данных с пагинацией, предоставляя удобный интерфейс для отображения загруженных элементов, обработки состояний загрузки и ошибок, а также предварительной загрузки данных для следующих страниц

## 1.8.0 - 02.2024
* Добавлен `TokenStorage`, `userChangedProvider` и `userAuthorizedProvider`

## 1.7.0 - 02.2024
* Добавлен `DurationUtilsX`
* В `ApiWrapController` добавлены методы для ручного завершения `Debounce` и `Throttle`
* Теперь `ApiWrap` будет корректно обрабатывать `ApiError`, не оборачивая его ещё в один
* Рефакторинг `RateLimiter`

## 1.6.0 - 01.2024
* Улучшение и ренейминг в `ApiWrap` API. Обновлена документация и добавлены Strict-методы, которые могут выдавать ошибку по умолчанию, если не задан onError
* В `ApiWrap` добавлен generic `ErrorType`, в `ApiWrapController` - метод `parseError`. Это позваляет задать кастомный тип ошибки и в onError работать напрямую с ним

## 1.5.0 - 01.2024
* Новое API валидаторов, теперь они принимают функцию `getState` для получения состояния для валидации и саму функцию валидации.
* Асинхронные функции валидации теперь могут принимать `softMode`

## 1.4.0 - 01.2024
* Рефакторинг `RateLimiter`
* Параметр `includeRequestTime` в `Throttle` заменён на enum `cooldownLaunch`, в `Debounce` - на `shouldCancelRunningOperations` для предоставления более понятного и очевидного API
* Добавлены параметры `cooldownTickDelay`, `onTickCooldown`, `onStartCooldown`, `onEndCooldown` в `Throttle` для возможности обработки кулдауна в приложении

## 1.3.0 - 01.2024
* Ренейминг `ErrorReponse` -> `ApiError`
* Добавлен `ErrorType` в `ApiError`, позволяющий использовать кастомные классы ошибок, специфичных для приложения или бэкенда

## 1.2.1 - 12.2023
* Исправление и рефакторинг метода `setError` в `SingleValidatorBase`

## 1.2.0 - 12.2023
* Добавлен параметр `errorVisibility` в `ApiWrap`

## 1.1.0 - 12.2023 
* Добавлен параметр `executeIf` в `ApiWrap`

## 1.0.0 - 12.2023
* Initial version
* Добавлен `ApiWrap`, позволяющий более удобно и безопасно работать с любым API, предоставляя методы для обработки разных результатов функций с автоматической или ручной обработкой ошибок
* Добавлен `RateLimiter` в `ApiWrap`, позволяющий бесшовно реализовать `Debounce` и `Throttle` для любых функций
* Добавлен `Retry` в `ApiWrap`, позволяющий возможности при ошибке отправлять запросы повторно через регулируемое время
* Добавлены `SingleValidator` и `AsyncSingleValidator`, которые с помощью `Riverpod` выполняют всю работу по управлению состоянием и предоставляют методы, позволяющие реализовать различные типы валидации
* Добавлен `PersistenceMixin`, позволяющий сохранять состояние `Notifier` при выходе из приложения
* Добавлено расширение `AsyncUtils`, предоставляющий методы для более удобного управления асинхронным состоянием в `AsyncNotifier`
* Добавлены виджеты `AutoUnfocus`, `SliverBottomAlign` и `ToastCard`