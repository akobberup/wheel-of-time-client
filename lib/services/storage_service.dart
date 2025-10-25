import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';

  // Secure storage for mobile
  static const _secureStorage = FlutterSecureStorage();

  // Shared preferences for web
  SharedPreferences? _prefs;

  Future<void> _ensurePrefs() async {
    if (kIsWeb && _prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  Future<void> saveAuthData({
    required String token,
    required int userId,
    required String name,
    required String email,
  }) async {
    if (kIsWeb) {
      await _ensurePrefs();
      await Future.wait([
        _prefs!.setString(_tokenKey, token),
        _prefs!.setString(_userIdKey, userId.toString()),
        _prefs!.setString(_userNameKey, name),
        _prefs!.setString(_userEmailKey, email),
      ]);
    } else {
      await Future.wait([
        _secureStorage.write(key: _tokenKey, value: token),
        _secureStorage.write(key: _userIdKey, value: userId.toString()),
        _secureStorage.write(key: _userNameKey, value: name),
        _secureStorage.write(key: _userEmailKey, value: email),
      ]);
    }
  }

  Future<String?> getToken() async {
    if (kIsWeb) {
      await _ensurePrefs();
      return _prefs!.getString(_tokenKey);
    } else {
      return await _secureStorage.read(key: _tokenKey);
    }
  }

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

  Future<void> clearAuthData() async {
    if (kIsWeb) {
      await _ensurePrefs();
      await Future.wait([
        _prefs!.remove(_tokenKey),
        _prefs!.remove(_userIdKey),
        _prefs!.remove(_userNameKey),
        _prefs!.remove(_userEmailKey),
      ]);
    } else {
      await Future.wait([
        _secureStorage.delete(key: _tokenKey),
        _secureStorage.delete(key: _userIdKey),
        _secureStorage.delete(key: _userNameKey),
        _secureStorage.delete(key: _userEmailKey),
      ]);
    }
  }
}
