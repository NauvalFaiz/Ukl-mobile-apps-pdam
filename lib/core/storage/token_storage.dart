import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _keyAppKey = 'app_key';
  static const String _keyJwtToken = 'jwt_token';
  static const String _keyRole = 'user_role';

  final SharedPreferences _prefs;

  TokenStorage(this._prefs);

  // --- App Key ---
  Future<void> saveAppKey(String appKey) async {
    await _prefs.setString(_keyAppKey, appKey);
  }

  String? getAppKey() {
    return _prefs.getString(_keyAppKey);
  }

  // --- JWT Token ---
  Future<void> saveJwt(String jwt) async {
    await _prefs.setString(_keyJwtToken, jwt);
  }

  String? getJwt() {
    return _prefs.getString(_keyJwtToken);
  }

  // --- User Role ---
  Future<void> saveRole(String role) async {
    await _prefs.setString(_keyRole, role);
  }

  String? getRole() {
    return _prefs.getString(_keyRole);
  }

  // --- Clear on Logout ---
  Future<void> clearUserTokens() async {
    await _prefs.remove(_keyJwtToken);
    await _prefs.remove(_keyRole);
  }
}
