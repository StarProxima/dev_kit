/// Library for App Update.
library app_update;

// TODO:
// 1) [x] Fetch и другие методы в UpdateController
// 2) [x] Реализация findAllAvailableUpdates в UpdateController
// 3) [x] UpdateConfigFetcher - получение и парсинг с remote url (для тестов можно оставить файл)
// 4) [x] SourceReleaseFetcher для Google Play и AppStore
// 5) [ ] Реализация UpdateAlertHandler.primaryDialog
// 6) [x] Тесты на Parser
// 7) [x] Интеграционные тесты нескольких компонентов
// 8) [ ] Обновить спеку и README
// 9) [x] Переименовать date_utc -> date. Чекать таймзону пожно по постфиксу Z.
 
// 10) [ ] Можно сделать отдельные модельный для оверайда (ReleaseConfigOverride, GlobalSourceConfigOverride, ReleaseSourceConfigOverride)
// Тогда получится в ReleaseConfig сохранить non-null version, в оверрайде убрать sources. 
// GlobalSourceConfig сохранить non-null name и url, в оверрайде убрать platforms.
// + Могда мерж нада будет писать только для ReleaseConfig + ReleaseConfigOverride. 
// И не будет циклов (что мы переопределяем в сурсе релиз, а в нём сурсы и т.д.).
// Что скажешь?
//
// Го сделаем только GlobalSourceConfigOverride и хватит

// 11) [ ] Вынести все текста как?
// settings:
//  texts:
//    title: ...
//    description: ...
//    

// 12) [ ] Доработать линкер и написать под него тесты, см. TODO в UpdateConfigLinker

// CANCELLED - ОТМЕНЕНА
// 13) [-] Логика мержа (или инхерита) - когда задаётся base,
// мы меняем не только исходный base, но и удаляем все варианты, оставляя только те, которые заданы.
// 
// Если юзер задаст:
// text:
//  title: Title
// Чтобы будет распаршено, как base locale -> base alert type -> base status -> title: Title
// То, абсолютно для всех локалей, типов и статусов должен быть title: Title.
// Т.е. если в дефолтный настрайках был какой-то отдельный title для deprecated, например, он не используется.
// 
// (?) Для UpdateSettings нужно исключение для required?
// Т.к. если юзер задаст:
// settings:
//  can_skip_release: true
// То обязательное обновление тоже можно будет скипнуть??
// Мб нужно, чтобы для него конкретно задали что-то:
// settings:
//  required:
//   can_skip_release: true
// РЕШЕНО - делаем логику получения отдельного UpdateSettings в getByBase

// 14 [ ]
// Мержить дефолтный контейнер и контейнером Controller и с контейнером ReleaseData, чтобы получить один,
// который передать в Release, из которого будет вытаскиваться нужные настройки или текст (по пункт. 13)