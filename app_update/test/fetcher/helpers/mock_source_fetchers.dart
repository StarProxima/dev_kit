import 'package:app_update/app_update.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Mock classes для source fetchers (так как они ходят в сеть)
class MockGooglePlayFetcher extends Mock implements GooglePlayFetcher {}

class MockAppStoreFetcher extends Mock implements AppStoreFetcher {}

class MockRuStoreFetcher extends Mock implements RuStoreFetcher {}

class MockUpdateConfigFetcher extends Mock implements UpdateConfigFetcher {}

class MockUpdateConfigSourceFetcher extends Mock
    implements UpdateConfigSourceFetcher {
  // Мокируемые методы через mocktail API
}

class MockUpdateConfigParser extends Mock implements UpdateConfigParser {}

class MockUpdateSearchDataDefaulter extends Mock
    implements UpdateSearchDataDefaulter {}

// Fake classes для fallback значений
class FakePackageInfo extends Fake implements PackageInfo {
  @override
  String get packageName => 'com.test.app';
  @override
  String get version => '1.0.0';
  @override
  String get buildNumber => '1';
  @override
  String get appName => 'Test App';
}

class FakeUpdateSearchConfig extends Fake implements UpdateSearchConfig {}
