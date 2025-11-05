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
    required String refreshToken,
    required int userId,
    required String name,
    required String email,
  }) async {
    developer.log('💾 STORAGE SAVE - Platform: ${kIsWeb ? "WEB" : "MOBILE"}', name: 'StorageService');
    developer.log('💾 Saving refreshToken: ${refreshToken.substring(0, 8)}...', name: 'StorageService');

    if (kIsWeb) {
      await _ensurePrefs();
      developer.log('💾 SharedPreferences instance: ${_prefs.hashCode}', name: 'StorageService');
      // Execute all writes in parallel for better performance
      await Future.wait([
        _prefs!.setString(_tokenKey, token),
        _prefs!.setString(_refreshTokenKey, refreshToken),
        _prefs!.setString(_userIdKey, userId.toString()),
        _prefs!.setString(_userNameKey, name),
        _prefs!.setString(_userEmailKey, email),
      ]);
      // Verify write
      final saved = _prefs!.getString(_refreshTokenKey);
      developer.log('💾 Verified save - refreshToken now: ${saved?.substring(0, 8)}...', name: 'StorageService');
    } else {
      // Mobile: use secure encrypted storage
      await Future.wait([
        _secureStorage.write(key: _tokenKey, value: token),
        _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
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

  /// Retrieves the refresh token from storage.
  /// Returns null if no refresh token is stored.
  Future<String?> getRefreshToken() async {
    if (kIsWeb) {
      await _ensurePrefs();
      return _prefs!.getString(_refreshTokenKey);
    } else {
      return await _secureStorage.read(key: _refreshTokenKey);
    }
  }

  /// Retrieves all stored authentication data.
  /// Returns a map containing token, refreshToken, userId, name, and email.
  /// Any missing values will be null in the returned map.
  Future<Map<String, String?>> getAuthData() async {
    developer.log('📖 STORAGE READ - Platform: ${kIsWeb ? "WEB" : "MOBILE"}', name: 'StorageService');

    if (kIsWeb) {
      await _ensurePrefs();
      developer.log('📖 SharedPreferences instance: ${_prefs.hashCode}', name: 'StorageService');

      final refreshToken = _prefs!.getString(_refreshTokenKey);
      developer.log('📖 Read refreshToken: ${refreshToken != null ? "${refreshToken.substring(0, 8)}..." : "NULL"}', name: 'StorageService');

      // List all keys in SharedPreferences for debugging
      final keys = _prefs!.getKeys();
      developer.log('📖 All SharedPreferences keys: $keys', name: 'StorageService');

      return {
        'token': _prefs!.getString(_tokenKey),
        'refreshToken': refreshToken,
        'userId': _prefs!.getString(_userIdKey),
        'name': _prefs!.getString(_userNameKey),
        'email': _prefs!.getString(_userEmailKey),
      };
    } else {
      // Read all values in parallel for better performance
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

  /// Clears all stored authentication data.
  /// Called during logout to remove all user session information.
  Future<void> clearAuthData() async {
    if (kIsWeb) {
      await _ensurePrefs();
      // Remove all auth-related keys in parallel
      await Future.wait([
        _prefs!.remove(_tokenKey),
        _prefs!.remove(_refreshTokenKey),
        _prefs!.remove(_userIdKey),
        _prefs!.remove(_userNameKey),
        _prefs!.remove(_userEmailKey),
      ]);
    } else {
      // Delete all auth-related keys from secure storage in parallel
      await Future.wait([
        _secureStorage.delete(key: _tokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
        _secureStorage.delete(key: _userIdKey),
        _secureStorage.delete(key: _userNameKey),
        _secureStorage.delete(key: _userEmailKey),
      ]);
    }
  }
}
