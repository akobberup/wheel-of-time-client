import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../l10n/strings_da.dart';
import '../l10n/strings_en.dart';

/// Service til håndtering af batterioptimering på Android.
///
/// Android's Doze mode og Battery Saver kan forhindre background tasks
/// i at køre pålideligt. Denne service beder brugeren om at undtage
/// appen fra batterioptimering for at sikre pålidelige notifikationer.
class BatteryOptimizationService {
  static const String _hasAskedKey = 'has_asked_battery_optimization';

  /// Henter AppStrings baseret på gemt sprogpræference.
  ///
  /// Læser sprogkode fra SharedPreferences og returnerer den tilsvarende
  /// strings-implementation. Fallback til dansk hvis ingen præference er gemt.
  static Future<AppStrings> _getLocalizedStrings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('locale_language_code') ?? 'da';

      switch (languageCode) {
        case 'en':
          return StringsEn();
        case 'da':
        default:
          return StringsDa();
      }
    } catch (e) {
      developer.log('Error getting locale preference: $e', name: 'BatteryOptimizationService');
      return StringsDa();
    }
  }

  /// Tjekker om batterioptimering er deaktiveret for appen.
  ///
  /// Returnerer true hvis appen er undtaget fra batterioptimering,
  /// eller hvis platformen ikke understøtter dette (iOS, web, desktop).
  static Future<bool> isOptimizationDisabled() async {
    if (!_isAndroid()) return true;

    try {
      final isDisabled = await DisableBatteryOptimization.isBatteryOptimizationDisabled;
      developer.log('Battery optimization disabled: $isDisabled', name: 'BatteryOptimizationService');
      return isDisabled ?? false;
    } catch (e) {
      developer.log('Error checking battery optimization: $e', name: 'BatteryOptimizationService');
      return false;
    }
  }

  /// Viser system-dialog der beder brugeren om at deaktivere batterioptimering.
  ///
  /// Denne dialog sendes direkte til Android's system-indstillinger.
  /// Returnerer true hvis brugeren accepterede, false ellers.
  static Future<bool> requestDisableOptimization() async {
    if (!_isAndroid()) return true;

    try {
      final result = await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
      developer.log('Battery optimization request result: $result', name: 'BatteryOptimizationService');
      return result ?? false;
    } catch (e) {
      developer.log('Error requesting battery optimization disable: $e', name: 'BatteryOptimizationService');
      return false;
    }
  }

  /// Viser en custom dialog der forklarer hvorfor batterioptimering skal deaktiveres.
  ///
  /// Bruger pakken's built-in dialog med lokaliseret tekst baseret på
  /// brugerens sprogpræference fra SharedPreferences.
  /// Returnerer true hvis brugeren accepterede at gå til indstillinger.
  static Future<bool> showExplanationDialog() async {
    if (!_isAndroid()) return true;

    try {
      final strings = await _getLocalizedStrings();
      final result = await DisableBatteryOptimization.showDisableManufacturerBatteryOptimizationSettings(
        strings.batteryOptimizationTitle,
        strings.batteryOptimizationMessage,
      );
      return result ?? false;
    } catch (e) {
      developer.log('Error showing explanation dialog: $e', name: 'BatteryOptimizationService');
      return false;
    }
  }

  /// Tjekker og beder om batterioptimering hvis nødvendigt.
  ///
  /// Denne metode kaldes ved app-start og viser kun dialogen én gang
  /// (medmindre brugeren stadig har batterioptimering aktiveret).
  /// Returnerer true hvis batterioptimering er deaktiveret efter check.
  static Future<bool> checkAndRequestIfNeeded() async {
    if (!_isAndroid()) return true;

    // Tjek om vi allerede har spurgt brugeren
    final prefs = await SharedPreferences.getInstance();
    final hasAsked = prefs.getBool(_hasAskedKey) ?? false;

    // Tjek aktuel status
    final isDisabled = await isOptimizationDisabled();
    if (isDisabled) {
      developer.log('Battery optimization already disabled', name: 'BatteryOptimizationService');
      return true;
    }

    // Hvis vi ikke har spurgt før, eller hvis optimering stadig er aktiv
    if (!hasAsked) {
      developer.log('Showing battery optimization dialog', name: 'BatteryOptimizationService');

      // Marker at vi har spurgt
      await prefs.setBool(_hasAskedKey, true);

      // Vis dialog
      await showExplanationDialog();

      // Tjek om brugeren accepterede
      return await isOptimizationDisabled();
    }

    return false;
  }

  /// Nulstiller "har spurgt" status, så dialogen vises igen.
  ///
  /// Bruges primært til test eller hvis brugeren vil ændre indstillinger.
  static Future<void> resetAskedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasAskedKey);
  }

  /// Åbner direkte Android's batteriindstillinger for appen.
  static Future<void> openBatterySettings() async {
    if (!_isAndroid()) return;

    try {
      await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
    } catch (e) {
      developer.log('Error opening battery settings: $e', name: 'BatteryOptimizationService');
    }
  }

  static bool _isAndroid() {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }
}
