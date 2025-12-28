import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier til håndtering af appens sprogindstilling.
///
/// Gemmer sprogpræferencen i SharedPreferences så den kan læses af
/// baggrundstasks og NotificationService uden adgang til BuildContext.
class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'locale_language_code';

  LocaleNotifier() : super(const Locale('da')) {
    _loadSavedLocale();
  }

  /// Indlæser gemt sprogpræference fra SharedPreferences.
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString(_localeKey);
      if (savedLanguageCode != null) {
        state = Locale(savedLanguageCode);
      }
    } catch (e) {
      // Ignorer fejl og behold standard (dansk)
    }
  }

  /// Sætter sproget og gemmer præferencen.
  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _saveLocale(locale.languageCode);
  }

  /// Skifter mellem dansk og engelsk.
  Future<void> toggleLocale() async {
    final newLocale = state.languageCode == 'da'
        ? const Locale('en')
        : const Locale('da');
    state = newLocale;
    await _saveLocale(newLocale.languageCode);
  }

  /// Gemmer sprogkoden i SharedPreferences.
  Future<void> _saveLocale(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, languageCode);
    } catch (e) {
      // Ignorer fejl ved gemning
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
