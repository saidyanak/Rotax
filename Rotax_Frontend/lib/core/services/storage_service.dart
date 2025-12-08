import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  static SharedPreferences? _prefs;
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _roleKey = 'user_role';
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Secure Storage - Token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
  
  // Shared Preferences - User Data
  static Future<void> saveUserData(String userData) async {
    await _prefs?.setString(_userKey, userData);
  }
  
  static String? getUserData() {
    return _prefs?.getString(_userKey);
  }
  
  static Future<void> deleteUserData() async {
    await _prefs?.remove(_userKey);
  }
  
  // User Role
  static Future<void> saveUserRole(String role) async {
    await _prefs?.setString(_roleKey, role);
  }
  
  static String? getUserRole() {
    return _prefs?.getString(_roleKey);
  }
  
  // Clear All
  static Future<void> clearAll() async {
    await _storage.deleteAll();
    await _prefs?.clear();
  }
}
