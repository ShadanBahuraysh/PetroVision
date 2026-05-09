// ========================================================================================================
// PetroVision Language Controller
// --------------------------------------------------------------------------------------------------------
// This file defines the LanguageController used
// for managing application language settings
// within the PetroVision platform.
//
// Features included:
// - Managing application locale settings
// - Supporting language switching functionality
// - Persisting selected language preferences
// - Loading saved language settings on startup
// - Supporting Arabic and English localization
// - Notifying UI listeners about language changes
//
// It also centralizes localization-state
// management and persistent language
// preference handling within the
// PetroVision application.
// ========================================================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  static const _key = 'app_locale';

  Locale _locale = const Locale('en');
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  LanguageController() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'en';

    _locale = Locale(code);
    notifyListeners();
  } catch (_) {
    _locale = const Locale('en');
  }
}

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}
