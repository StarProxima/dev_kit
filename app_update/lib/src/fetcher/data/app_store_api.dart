// ignore_for_file: avoid-type-casts

import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart' as http;

/// API helper для работы с iTunes Search API.
class AppStoreApi {
  const AppStoreApi();

  /// Получает информацию о приложении по bundle ID
  /// Использует fallback логику: если не найдено с исходной локалью, убирает страну.
  Future<Map<String, dynamic>?> lookupApp({
    required String bundleId,
    required Locale locale,
    bool shouldUseFallback = true,
  }) async {
    Map<String, dynamic>? appData = await _tryLookupApp(bundleId, locale);

    // Если не найдено и есть страна, пробуем без страны (fallback)
    // ignore: avoid-unused-after-null-check
    if (shouldUseFallback && appData == null && locale.countryCode != null) {
      final fallbackLocale = Locale(locale.languageCode);
      appData = await _tryLookupApp(bundleId, fallbackLocale);
    }

    return appData;
  }

  /// Пытается найти приложение с определенной локалью.
  Future<Map<String, dynamic>?> _tryLookupApp(
    String bundleId,
    Locale locale,
  ) async {
    final url = _buildLookupUrl(bundleId, locale);
    final response = await http.get(url);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final jsonResponse = response.body;
    if (jsonResponse.isEmpty) return null;

    final decodedResults = json.decode(jsonResponse) as Map<String, dynamic>;
    final resultCount = decodedResults['resultCount'] as int?;

    if (resultCount == null || resultCount == 0) return null;

    final results = decodedResults['results'] as List?;

    final firstResult = results?.firstOrNull;
    if (results == null || firstResult == null) return null;

    return firstResult as Map<String, dynamic>;
  }

  /// Создает URL для App Store страницы приложения на основе данных из iTunes API.
  String? buildAppStoreUrl(Map<String, dynamic> appData, Locale locale) {
    final trackViewUrl = appData['trackViewUrl'] as String?;
    if (trackViewUrl == null) return null;

    final languageCode = locale.languageCode;

    // Заменяем локаль в URL
    final updatedUrl = trackViewUrl.replaceFirst(
      RegExp(r'apps\.apple\.com\/.*\/app'),
      'apps.apple.com/$languageCode/app',
    );

    return updatedUrl;
  }

  static Uri _buildLookupUrl(String bundleId, Locale locale) {
    final queryParams = <String, String>{
      'bundleId': bundleId,
    };

    // Добавляем страну и язык если доступны
    final countryCode = locale.countryCode;
    if (countryCode != null && countryCode.isNotEmpty) {
      queryParams['country'] = countryCode.toUpperCase();
    }

    final languageCode = locale.languageCode;
    if (languageCode.isNotEmpty) {
      queryParams['lang'] = languageCode;
    }

    return Uri.https('itunes.apple.com', 'lookup', queryParams);
  }
}
