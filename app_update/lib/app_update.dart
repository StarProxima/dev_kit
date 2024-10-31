/// Library for App Update.
library app_update;

// TODO:
// 1) [ ] Fetch и другие методы в UpdateController
// 2) [ ] Реализация findAllAvailableUpdates в UpdateController
// 3) [ ] UpdateConfigFetcher - получение и парсинг с remote url (для тестов можно оставить файл)
// 4) [ ] SourceReleaseFetcher для Google Play и AppStore
// 5) [ ] Реализация UpdateAlertHandler.materialDialog
// 6) [ ] Тесты на Parser
// 7) [ ] Интеграционные тесты нескольких компонентов
// 8) [ ] Обновить спеку и README
// 9) [x] Переименовать date_utc -> date. Чекать таймзону пожно по постфиксу Z.
 
// 10) [ ] Можно сделать отдельные модельный для оверайда (ReleaseConfigOverride, GlobalSourceConfigOverride, ReleaseSourceConfigOverride)
// Тогда получится в ReleaseConfig сохранить non-null version, в оверрайде убрать sources. 
// GlobalSourceConfig сохранить non-null name и url, в оверрайде убрать platforms.
// + Могда мерж нада будет писать только для ReleaseConfig + ReleaseConfigOverride. 
// И не будет циклов (что мы переопределяем в сурсе релиз, а в нём сурсы и т.д.).
// Что скажешь?

// 11) Вынести все текста как?
// settings:
//  texts:
//    title: ...
//    description: ...
//    
