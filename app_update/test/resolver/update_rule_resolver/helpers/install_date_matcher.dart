import 'package:app_update/app_update.dart';

/// Матчер для проверки времени, прошедшего с момента установки приложения.
/// Использует поле 'min_delay_after_app_install_hours' в customParams правила
/// и поле 'app_install_date' в customParams поиска для определения времени.
/// Должен выполняться ПЕРЕД customParamsMatcher, так как не использует суффикс '_is'.
class InstallDateMatcher extends RuleMatcher {
  const InstallDateMatcher();

  @override
  bool get canUseCustomParams => true;

  @override
  bool isMatches({
    required UpdateRuleConfig rule,
    required UpdateSearchData search,
  }) {
    final rulecustomParams = rule.customParams;
    if (rulecustomParams == null) return true;

    final delayHours = rulecustomParams['min_delay_after_app_install_hours'];
    if (delayHours == null) return true;

    if (delayHours is! int) return true;

    final searchcustomParams = search.customParams;
    if (searchcustomParams == null) return false;

    final appInstallDate = searchcustomParams['app_install_date'];
    if (appInstallDate is! DateTime) return false;

    final minDelay = Duration(hours: delayHours);
    final elapsedTime = search.currentDate.difference(appInstallDate);

    final isMatched = elapsedTime >= minDelay;

    // Удаляем обработанное поле из customParams для последующих матчеров
    if (isMatched) {
      rulecustomParams.remove('min_delay_after_app_install_hours');
    }

    return isMatched;
  }
}
