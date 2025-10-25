import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service class responsible for persistent storage of authentication data.
/// Uses platform-specific storage solutions:
/// - FlutterSecureStorage for mobile platforms (encrypted storage)
/// - SharedPreferences for web (browser local storage)
class StorageService {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';

  // Secure storage for mobile platforms - provides encrypted storage on iOS and Android
  static const _secureStorage = FlutterSecureStorage();

  // Shared preferences for web platform - uses browser's local storage
  SharedPreferences? _prefs;

  /// Ensures SharedPreferences is initialized for web platform.
  /// This lazy initialization approach avoids unnecessary initialization on mobile platforms.
  Future<void> _ensurePrefs() async {
    if (kIsWeb && _prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  /// Saves user authentication data to persistent storage.
  /// On web, uses SharedPreferences (local storage).
  /// On mobile, uses FlutterSecureStorage (encrypted storage) for enhanced security.
  /// All write operations are executed in parallel using Future.wait for better performance.
  Future<void> saveAuthData({
    required String token,
    required int userId,
    required String name,
    required String email,
  }) async {
    if (kIsWeb) {
      await _ensurePrefs();
      // Execute all writes in parallel for better performance
      await Future.wait([
        _prefs!.setString(_tokenKey, token),
        _prefs!.setString(_userIdKey, userId.toString()),
        _prefs!.setString(_userNameKey, name),
        _prefs!.setString(_userEmailKey, email),
      ]);
    } else {
      // Mobile: use secure encrypted storage
      await Future.wait([
        _secureStorage.write(key: _tokenKey, value: token),
        _secureStorage.write(key: _userIdKey, value: userId.toString()),
        _secureStorage.write(key: _userNameKey, value: name),
        _secureStorage.write(key: _userEmailKey, value: email),
      ]);
    }
  }

  /// Retrieves the authentication token from storage.
  /// Returns null if no token is stored.
  Future<String?> getToken() async {
    if (kIsWeb) {
      await _ensurePrefs();
      return _prefs!.getString(_tokenKey);
    } else {
      return await _secureStorage.read(key: _tokenKey);
    }
  }

  /// Retrieves all stored authentication data.
  /// Returns a map containing token, userId, name, and email.
  /// Any missing values will be null in the returned map.
  Future<Map<String, String?>> getAuthData() async {
    if (kIsWeb) {
      await _ensurePrefs();
      return {
        'token': _prefs!.getString(_tokenKey),
        'userId': _prefs!.getString(_userIdKey),
        'name': _prefs!.getString(_userNameKey),
        'email': _prefs!.getString(_userEmailKey),
      };
    } else {
      // Read all values in parallel for better performance
      final values = await Future.wait([
        _secureStorage.read(key: _tokenKey),
        _secureStorage.read(key: _userIdKey),
        _secureStorage.read(key: _userNameKey),
        _secureStorage.read(key: _userEmailKey),
      ]);

      return {
        'token': values[0],
        'userId': values[1],
        'name': values[2],
        'email': values[3],
      };
    }
  }

  /// Clears all stored authentication data.
  /// Called during logout to remove all user session information.
  Future<void> clearAuthData() async {
    if (kIsWeb) {
      await _ensurePrefs();
      // Remove all auth-related keys in parallel
      await Future.wait([
        _prefs!.remove(_tokenKey),
        _prefs!.remove(_userIdKey),
        _prefs!.remove(_userNameKey),
        _prefs!.remove(_userEmailKey),
      ]);
    } else {
      // Delete all auth-related keys from secure storage in parallel
      await Future.wait([
        _secureStorage.delete(key: _tokenKey),
        _secureStorage.delete(key: _userIdKey),
        _secureStorage.delete(key: _userNameKey),
        _secureStorage.delete(key: _userEmailKey),
      ]);
    }
  }
}
