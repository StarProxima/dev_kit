import 'dart:ui';

/// Тестовые локали для различных сценариев
abstract final class TestLocales {
  /// Английская локаль (США) - базовая для большинства тестов
  static const english = Locale('en', 'US');

  /// Корейская локаль - для региональных приложений
  static const korean = Locale('ko', 'KR');

  /// Русская локаль - для тестов локализации
  static const russian = Locale('ru', 'RU');

  /// Французская локаль - альтернативная европейская
  static const french = Locale('fr', 'FR');

  /// Только английский язык без страны - для fallback тестов
  static const englishOnly = Locale('en');

  /// Только корейский язык без страны
  static const koreanOnly = Locale('ko');

  /// Только русский язык без страны - для fallback тестов
  static const russianOnly = Locale('ru');

  /// Список основных тестовых локалей
  static const main = [english, korean, russian, french];

  /// Список локалей для fallback тестов
  static const fallbackTest = [english, korean, englishOnly, koreanOnly];

  /// Получает описание локали для логов
  static String describe(Locale locale) {
    if (locale.countryCode != null) {
      return '${locale.languageCode}-${locale.countryCode}';
    }

    return locale.languageCode;
  }
}
