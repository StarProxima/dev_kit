/// Типы доступных тестовых конфигураций
enum UpdateConfigType {
  optional('test_optional_update.yaml'),
  critical('test_critical_update.yaml'),
  recommended('test_recommended_update.yaml');

  const UpdateConfigType(this.fileName);

  final String fileName;

  /// Человекочитаемое название конфигурации
  String get displayName {
    return switch (this) {
      UpdateConfigType.optional => 'Опциональное обновление',
      UpdateConfigType.critical => 'Критическое обновление',
      UpdateConfigType.recommended => 'Рекомендуемое обновление',
    };
  }
}
