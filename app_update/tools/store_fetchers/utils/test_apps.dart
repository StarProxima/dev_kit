/// Тестовые приложения для интеграционных тестов
abstract final class TestApps {
  /// Популярное приложение (должно быть во всех сторах)
  static const multiStoreApp = TestAppData(
    name: 'Yandex Go',
    androidPackageId: 'ru.yandex.taxi',
    iosPackageId: 'ru.yandex.ytaxi',
  );

  // static const multiStoreApp = TestAppData(
  //   name: 'Max',
  //   androidPackageId: 'ru.oneme.app',
  //   iosPackageId: 'ru.oneme.app',
  // );

  /// Региональное приложение (доступно только в Корее)
  static const onlyKoreanApp = TestAppData(
    name: 'Melon',
    androidPackageId: 'com.iloen.melon',
    iosPackageId: 'com.iloen.iphonemelon',
  );

  /// Приложение, которое не доступно в России, но есть в других странах
  static const nonRuApp = TestAppData(
    name: 'ChatGPT',
    androidPackageId: 'com.openai.chatgpt',
    iosPackageId: 'com.openai.chat',
  );

  /// Несуществующее приложение для негативных тестов
  static const nonExistentApp = TestAppData(
    name: 'NonExistentApp',
    androidPackageId: 'com.fake.nonexistent.app.12345',
    iosPackageId: 'com.fake.nonexistent.app.12345',
  );
}

class TestAppData {
  final String name;
  final String androidPackageId;
  final String iosPackageId;

  const TestAppData({
    required this.name,
    required this.androidPackageId,
    required this.iosPackageId,
  });

  /// Получает package ID для указанной платформы
  String getPackageId(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.android:
        return androidPackageId;

      case TargetPlatform.ios:
        return iosPackageId;
    }
  }
}

enum TargetPlatform { android, ios }
