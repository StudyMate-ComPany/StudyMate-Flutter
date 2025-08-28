import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class LocalStorageService {
  static const String _authTokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _settingsKey = 'app_settings';
  static const String _studyDataKey = 'offline_study_data';

  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('LocalStorageService not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  // Auth Token Management
  static Future<void> saveAuthToken(String token) async {
    await prefs.setString(_authTokenKey, token);
  }

  static String? getAuthToken() {
    return prefs.getString(_authTokenKey);
  }

  static Future<void> clearAuthToken() async {
    await prefs.remove(_authTokenKey);
  }

  // User Data Management
  static Future<void> saveUser(User user) async {
    final userJson = json.encode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  static User? getUser() {
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        final userData = json.decode(userJson) as Map<String, dynamic>;
        return User.fromJson(userData);
      } catch (e) {
        // If there's an error parsing user data, clear it
        prefs.remove(_userKey);
        return null;
      }
    }
    return null;
  }

  static Future<void> clearUser() async {
    await prefs.remove(_userKey);
  }

  // App Settings
  static Future<void> saveSetting(String key, dynamic value) async {
    final settings = getSettings();
    settings[key] = value;
    final settingsJson = json.encode(settings);
    await prefs.setString(_settingsKey, settingsJson);
  }

  static Map<String, dynamic> getSettings() {
    final settingsJson = prefs.getString(_settingsKey);
    if (settingsJson != null) {
      try {
        return json.decode(settingsJson) as Map<String, dynamic>;
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  static T? getSetting<T>(String key, [T? defaultValue]) {
    final settings = getSettings();
    return settings[key] as T? ?? defaultValue;
  }

  static Future<void> clearSettings() async {
    await prefs.remove(_settingsKey);
  }

  // Offline Study Data
  static Future<void> saveOfflineStudyData(String key, Map<String, dynamic> data) async {
    final allData = getOfflineStudyData();
    allData[key] = data;
    final dataJson = json.encode(allData);
    await prefs.setString(_studyDataKey, dataJson);
  }

  static Map<String, dynamic> getOfflineStudyData() {
    final dataJson = prefs.getString(_studyDataKey);
    if (dataJson != null) {
      try {
        return json.decode(dataJson) as Map<String, dynamic>;
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  static Future<void> clearOfflineStudyData() async {
    await prefs.remove(_studyDataKey);
  }

  static Future<void> removeOfflineStudyData(String key) async {
    final allData = getOfflineStudyData();
    allData.remove(key);
    final dataJson = json.encode(allData);
    await prefs.setString(_studyDataKey, dataJson);
  }

  // General String Storage
  static Future<void> saveString(String key, String value) async {
    await prefs.setString(key, value);
  }
  
  static Future<String?> getString(String key) async {
    return prefs.getString(key);
  }
  
  // Complete cleanup
  static Future<void> clearAll() async {
    await prefs.clear();
  }

  // Check if user is logged in
  static bool get isLoggedIn {
    return getAuthToken() != null && getUser() != null;
  }

  // Theme and UI preferences
  static Future<void> setThemeMode(String themeMode) async {
    await saveSetting('theme_mode', themeMode);
  }

  static String getThemeMode() {
    return getSetting<String>('theme_mode', 'system') ?? 'system';
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    await saveSetting('notifications_enabled', enabled);
  }

  static bool getNotificationsEnabled() {
    return getSetting<bool>('notifications_enabled', true) ?? true;
  }

  static Future<void> setStudyRemindersEnabled(bool enabled) async {
    await saveSetting('study_reminders_enabled', enabled);
  }

  static bool getStudyRemindersEnabled() {
    return getSetting<bool>('study_reminders_enabled', true) ?? true;
  }

  static Future<void> setDefaultStudyDuration(int minutes) async {
    await saveSetting('default_study_duration', minutes);
  }

  static int getDefaultStudyDuration() {
    return getSetting<int>('default_study_duration', 25) ?? 25;
  }
  
  // Generic Data Management for Pomodoro Settings
  static Future<void> saveData(String key, Map<String, dynamic> data) async {
    final jsonData = json.encode(data);
    await prefs.setString(key, jsonData);
  }
  
  static Map<String, dynamic>? getData(String key) {
    final jsonData = prefs.getString(key);
    if (jsonData != null) {
      try {
        return json.decode(jsonData) as Map<String, dynamic>;
      } catch (e) {
        print('Error parsing data for key $key: $e');
        return null;
      }
    }
    return null;
  }
}