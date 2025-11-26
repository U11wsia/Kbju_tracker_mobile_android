import 'package:flutter/material.dart';
import 'package:kbju_tracker/data/storage.dart';
import 'package:kbju_tracker/models/app_settings.dart';
import 'package:kbju_tracker/models/enums.dart';
import 'package:kbju_tracker/models/goals.dart';
import 'package:kbju_tracker/models/user_profile.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;
  SettingsProvider(this._storage);

  bool _ready = false;
  bool get isReady => _ready;

  AppSettings _settings = AppSettings.defaults;
  AppSettings get settings => _settings;

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  Future<void> init() async {
    _settings = await _storage.loadSettings();
    _profile  = await _storage.loadProfile();
    _ready = true;
    notifyListeners();
  }

  Future<void> saveSettings(AppSettings s) async {
    _settings = s;
    await _storage.saveSettings(s);
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile p) async {
    _profile = p;
    await _storage.saveProfile(p);
    notifyListeners();
  }

  bool get isOnboarded => _profile != null;

  // Простая модель адаптивных целей — без возраста, только вес/активность/цель.
  Goals computeAdaptiveGoals() {
    final p = _profile;
    if (p == null) return Goals.defaults;

    // Базовая оценка суточной энергии (ккал/кг):
    // сидячий ~30, лёгкий ~33, средний ~36, высокий ~40
    double kcalPerKg;
    switch (p.activity) {
      case ActivityLevel.sedentary: kcalPerKg = 30; break;
      case ActivityLevel.light:     kcalPerKg = 33; break;
      case ActivityLevel.moderate:  kcalPerKg = 36; break;
      case ActivityLevel.high:      kcalPerKg = 40; break;
    }
    double maintenance = p.weightKg * kcalPerKg;

    // Сдвиг по цели: сушка −15%, набор +15%
    double adj;
    switch (p.goal) {
      case GoalType.lose:     adj = -0.15; break;
      case GoalType.maintain: adj =  0.00; break;
      case GoalType.gain:     adj =  0.15; break;
    }
    final calories = maintenance * (1 + adj);

    // Макро‑разклад: P — 1.6/1.8 г/кг (ж/м), F — 0.8 г/кг, C — остаток.
    final double proteinPerKg = (p.sex == Sex.male) ? 1.8 : 1.6;
    final double protein      = proteinPerKg * p.weightKg;
    final double fat          = 0.8 * p.weightKg;
    final double kcalFromPF   = protein * 4.0 + fat * 9.0;
    final double carbs        = (calories - kcalFromPF) > 0.0
        ? (calories - kcalFromPF) / 4.0
        : 0.0;

    return Goals(
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
    );
  }
}
