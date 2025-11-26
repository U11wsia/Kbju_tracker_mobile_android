import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_entry.dart';
import '../models/goals.dart';
import '../models/user_profile.dart';
import '../models/app_settings.dart';

class StorageService {
  static const _entriesKey   = 'kbju_entries_v1';
  static const _goalsKey     = 'kbju_goals_v1';
  static const _profileKey   = 'kbju_profile_v1';
  static const _settingsKey  = 'kbju_settings_v1';

  Future<List<FoodEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_entriesKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => FoodEntry.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> saveEntries(List<FoodEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_entriesKey, raw);
  }

  Future<Goals> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_goalsKey);
    if (raw == null || raw.isEmpty) return Goals.defaults;
    return Goals.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveGoals(Goals goals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_goalsKey, jsonEncode(goals.toJson()));
  }

  Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) return AppSettings.defaults;
    return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }
}
