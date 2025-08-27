/// Миксин для поддержки регулярных выражений в матчерах правил.
mixin RegExpMatcherMixin {
  static const _regexpPrefix = 'regexp:';

  /// Проверяет совпадение значения со списком возможных вариантов.
  /// Поддерживает:
  /// - Обычные строки: точное совпадение (case-insensitive)
  /// - 'any': всегда true
  /// - 'regexp:pattern': проверка по регулярному выражению
  bool matchesStringInListWithRegExp(
    String searchValue,
    List<String> ruleValues,
  ) {
    if (ruleValues.isEmpty) return false; // Пустой список никого не пускает

    // Проверка на 'any' в списке
    if (ruleValues.any((value) => value.toLowerCase() == 'any')) {
      return true;
    }

    final searchStr = searchValue.toLowerCase();

    // Проверяем каждое значение из списка правил
    for (final ruleValue in ruleValues) {
      final ruleStr = ruleValue.toLowerCase();

      // Проверка на регулярное выражение
      if (ruleStr.startsWith(_regexpPrefix)) {
        final pattern = ruleStr.substring(_regexpPrefix.length);
        try {
          final regex = RegExp(pattern, caseSensitive: false);
          if (regex.hasMatch(searchStr)) return true;
        } catch (e) {
          // Если регулярка невалидная, пропускаем
          continue;
        }
      } else if (ruleStr == searchStr) {
        // Обычное сравнение строк
        return true;
      }
    }

    return false;
  }
}
