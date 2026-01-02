import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier til håndtering af appens sprogindstilling.
///
/// Gemmer sprogpræferencen i SharedPreferences så den kan læses af
/// baggrundstasks og NotificationService uden adgang til BuildContext.
/// Ved første opstart detekteres systemsproget automatisk.
class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'locale_language_code';

  /// Liste af understøttede sprog i appen.
  static const List<String> _supportedLanguages = ['da', 'en'];

  LocaleNotifier() : super(const Locale('da')) {
    _loadSavedLocale();
  }

  /// Detekterer systemsproget og finder nærmeste match blandt understøttede sprog.
  /// Returnerer dansk hvis systemsproget er dansk, ellers engelsk som fallback.
  Locale _detectSystemLocale() {
    final systemLanguage = PlatformDispatcher.instance.locale.languageCode;

    if (_supportedLanguages.contains(systemLanguage)) {
      return Locale(systemLanguage);
    }
    return const Locale('en');
  }

  /// Indlæser gemt sprogpræference fra SharedPreferences.
  /// Hvis ingen præference er gemt, detekteres systemsproget.
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString(_localeKey);
      if (savedLanguageCode != null) {
        state = Locale(savedLanguageCode);
      } else {
        // Ingen gemt præference - brug systemsprog
        final detectedLocale = _detectSystemLocale();
        state = detectedLocale;
        // Gem det detekterede sprog så det kun sker ved første opstart
        await _saveLocale(detectedLocale.languageCode);
      }
    } catch (e) {
      // Log fejl i debug mode, men behold standard (dansk) i produktion
      debugPrint('Kunne ikke indlæse gemt sprog: $e');
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
      // Log fejl i debug mode, men ignorer i produktion
      debugPrint('Kunne ikke gemme sprogpræference: $e');
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
