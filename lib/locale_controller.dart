import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Resolves the active UI language: an explicit user choice (persisted), or
/// automatic detection from the browser/system locale — English if the
/// browser prefers English, German as the default for everything else.
class LocaleController extends ChangeNotifier {
  static const _prefsKey = 'neurowire_locale_override';
  static const _supportedLanguageCodes = ['de', 'en'];

  Locale? _override;

  /// Explicit user override, or null to follow the system/browser locale.
  Locale? get override => _override;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && _supportedLanguageCodes.contains(code)) {
      _override = Locale(code);
    }
  }

  Future<void> setOverride(Locale? locale) async {
    _override = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }

  /// German is the default/fallback; English is only picked when a system
  /// locale explicitly prefers it.
  static Locale resolveSystemLocale(List<Locale>? systemLocales) {
    final hasEnglish = (systemLocales ?? const []).any((l) => l.languageCode == 'en');
    return Locale(hasEnglish ? 'en' : 'de');
  }
}
