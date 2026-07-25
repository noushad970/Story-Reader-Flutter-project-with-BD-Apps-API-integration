import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String phoneKey = 'user_phone';
  static const String subscriberIdKey = 'subscriber_id';
  static const String loggedInKey = 'is_logged_in';

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
}
