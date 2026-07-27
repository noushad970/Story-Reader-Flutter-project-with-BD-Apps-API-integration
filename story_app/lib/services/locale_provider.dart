import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the user's chosen locale ("en" or "bn") and persists it.
class LocaleProvider extends ChangeNotifier {
  static const String _storageKey = 'app_locale';

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  bool get isBangla => _locale.languageCode == 'bn';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_storageKey);
    if (code == 'bn' || code == 'en') {
      _locale = Locale(code!);
      notifyListeners();
    }
  }

  Future<void> toggle() async {
    _locale = isBangla ? const Locale('en') : const Locale('bn');
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, _locale.languageCode);
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, locale.languageCode);
  }
}