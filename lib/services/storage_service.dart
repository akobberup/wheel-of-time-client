import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service class responsible for persistent storage of authentication data.
/// Uses platform-specific storage solutions:
/// - FlutterSecureStorage for mobile platforms (encrypted storage)
/// - SharedPreferences for web (browser local storage)
class StorageService {
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';

  // Secure storage for mobile platforms - provides encrypted storage on iOS and Android
  static const _secureStorage = FlutterSecureStorage();

  // Shared preferences for web platform - uses browser's local storage
  SharedPreferences? _prefs;

  /// Sikrer at SharedPreferences er initialiseret på web-platformen.
  ///
  /// Lazy initialization pattern undgår unødvendig initialisering på mobile platforme
  /// hvor vi primært bruger FlutterSecureStorage.
  Future<void> _ensureSharedPreferencesInitialized() async {
    if (kIsWeb && _prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  /// Gemmer brugerens autentificeringsdata i persistent storage.
  ///
  /// På web bruges SharedPreferences (browser local storage).
  /// På mobile bruges FlutterSecureStorage (krypteret storage) for forbedret sikkerhed.
  ///
  /// User ID gemmes også i SharedPreferences på mobile for at give baggrundstasks
  /// adgang til bruger-ID, da WorkManager's isolate-baserede execution model ikke
  /// kan tilgå FlutterSecureStorage. Dette er en kendt sikkerhedstrade-off der
  /// accepteres fordi user ID ikke er sensitiv information.
  ///
  /// Alle write-operationer køres parallelt med Future.wait for bedre performance.
  Future<void> saveAuthData({
    required String token,
    required String refreshToken,
    required int userId,
    required String name,
    required String email,
  }) async {
    if (kIsWeb) {
      await _ensureSharedPreferencesInitialized();

      // Udfør alle writes parallelt for bedre performance
      await Future.wait([
        _prefs!.setString(_tokenKey, token),
        _prefs!.setString(_refreshTokenKey, refreshToken),
        _prefs!.setString(_userIdKey, userId.toString()),
        _prefs!.setString(_userNameKey, name),
        _prefs!.setString(_userEmailKey, email),
      ]);
    } else {
      // Mobile: brug krypteret storage for alle følsomme data
      await Future.wait([
        _secureStorage.write(key: _tokenKey, value: token),
        _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
        _secureStorage.write(key: _userIdKey, value: userId.toString()),
        _secureStorage.write(key: _userNameKey, value: name),
        _secureStorage.write(key: _userEmailKey, value: email),
      ]);

      // Gem også user_id i SharedPreferences for baggrundstasks
      // (WorkManager kan ikke tilgå FlutterSecureStorage fra baggrunds-isolate)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_userIdKey, userId);
    }
  }

  /// Henter autentificerings-token fra storage.
  /// Returnerer null hvis intet token er gemt.
  Future<String?> getToken() async {
    if (kIsWeb) {
      await _ensureSharedPreferencesInitialized();
      return _prefs!.getString(_tokenKey);
    } else {
      return await _secureStorage.read(key: _tokenKey);
    }
  }

  /// Henter refresh token fra storage.
  /// Returnerer null hvis intet refresh token er gemt.
  Future<String?> getRefreshToken() async {
    if (kIsWeb) {
      await _ensureSharedPreferencesInitialized();
      return _prefs!.getString(_refreshTokenKey);
    } else {
      return await _secureStorage.read(key: _refreshTokenKey);
    }
  }

  /// Henter alle gemte autentificeringsdata.
  ///
  /// Returnerer et map med token, refreshToken, userId, name og email.
  /// Manglende værdier vil være null i det returnerede map.
  ///
  /// På mobile læses alle værdier parallelt med Future.wait for bedre performance.
  Future<Map<String, String?>> getAuthData() async {
    if (kIsWeb) {
      await _ensureSharedPreferencesInitialized();

      return {
        'token': _prefs!.getString(_tokenKey),
        'refreshToken': _prefs!.getString(_refreshTokenKey),
        'userId': _prefs!.getString(_userIdKey),
        'name': _prefs!.getString(_userNameKey),
        'email': _prefs!.getString(_userEmailKey),
      };
    } else {
      // Læs alle værdier parallelt for bedre performance
      final values = await Future.wait([
        _secureStorage.read(key: _tokenKey),
        _secureStorage.read(key: _refreshTokenKey),
        _secureStorage.read(key: _userIdKey),
        _secureStorage.read(key: _userNameKey),
        _secureStorage.read(key: _userEmailKey),
      ]);

      return {
        'token': values[0],
        'refreshToken': values[1],
        'userId': values[2],
        'name': values[3],
        'email': values[4],
      };
    }
  }

  /// Sletter alle gemte autentificeringsdata fra storage.
  ///
  /// Kaldes ved logout for at fjerne al brugersession-information.
  /// Rydder også notification-historik for at undgå at vise gamle
  /// notifikationer hvis en ny bruger logger ind på samme enhed.
  ///
  /// Alle delete-operationer køres parallelt med Future.wait for bedre performance.
  Future<void> clearAuthData() async {
    if (kIsWeb) {
      await _ensureSharedPreferencesInitialized();

      // Fjern alle auth-relaterede keys parallelt
      await Future.wait([
        _prefs!.remove(_tokenKey),
        _prefs!.remove(_refreshTokenKey),
        _prefs!.remove(_userIdKey),
        _prefs!.remove(_userNameKey),
        _prefs!.remove(_userEmailKey),
      ]);
    } else {
      // Slet alle auth-relaterede keys fra krypteret storage parallelt
      await Future.wait([
        _secureStorage.delete(key: _tokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
        _secureStorage.delete(key: _userIdKey),
        _secureStorage.delete(key: _userNameKey),
        _secureStorage.delete(key: _userEmailKey),
      ]);

      // Ryd også user_id og notification-historik fra SharedPreferences
      // (brugt af baggrundstasks til at undgå at vise samme notifikationer gentagne gange)
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
      await prefs.remove('seen_notification_ids');
    }
  }
}
