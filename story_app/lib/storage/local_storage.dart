import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String phoneKey = 'user_phone';
  static const String subscriberIdKey = 'subscriber_id';
  static const String loggedInKey = 'is_logged_in';
  static const String themeModeKey = 'theme_mode';
  static const String bookmarksKey = 'cached_bookmarks';

  static Future<void> saveUser({
    required String phone,
    required String subscriberId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(phoneKey, phone);
    await prefs.setString(subscriberIdKey, subscriberId);
    await prefs.setBool(loggedInKey, true);
  }

  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(phoneKey);
  }

  static Future<String?> getSubscriberId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(subscriberIdKey);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(loggedInKey) ?? false;
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(phoneKey);
    await prefs.remove(subscriberIdKey);
    await prefs.remove(loggedInKey);
  }

  // ============================================================
  // SYNC HELPERS
  // ============================================================

  static String? getPhoneSync() {
    final cached = _cachePhone;
    if (cached != null) return cached;
    final prefs = _prefsInstance;
    if (prefs == null) return null;
    return prefs.getString(phoneKey);
  }

  static Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeModeKey, mode);
  }

  static Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(themeModeKey);
  }

  static Future<void> setCachedBookmarks(List<String> storyIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(bookmarksKey, storyIds);
  }

  static Future<List<String>> getCachedBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(bookmarksKey) ?? <String>[];
  }

  // Internal cache used by sync getters to avoid repeated async hops
  static String? _cachePhone;
  static SharedPreferences? _prefsInstance;

  static Future<void> prime() async {
    _prefsInstance = await SharedPreferences.getInstance();
    _cachePhone = _prefsInstance?.getString(phoneKey);
  }
}
