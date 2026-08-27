import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  static const String keyCustomBaseUrl = 'custom_base_url';

  // Default IP for Android emulator is 10.0.2.2, for desktop/web is localhost
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8081/api/v1';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8081/api/v1';
    } else {
      return 'http://localhost:8081/api/v1';
    }
  }

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyCustomBaseUrl) ?? defaultBaseUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyCustomBaseUrl, url);
  }
}
