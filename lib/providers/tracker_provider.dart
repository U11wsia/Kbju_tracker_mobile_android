import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/storage.dart';
import '../models/food_entry.dart';
import '../models/goals.dart';

class TrackerProvider extends ChangeNotifier {
  final StorageService _storage;

  TrackerProvider(this._storage);

  bool _ready = false;
  bool get isReady => _ready;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  List<FoodEntry> _entries = [];
  List<FoodEntry> get entries => List.unmodifiable(_entries);

  Goals _goals = Goals.defaults;
  Goals get goals => _goals;

  Future<void> init() async {
    _entries = await _storage.loadEntries();
    _goals = await _storage.loadGoals();
    _ready = true;
    notifyListeners();
  }

  // Выбор дня (сброс часов/минут).
  void setSelectedDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<FoodEntry> get entriesForSelectedDate => _entries
      .where((e) => _isSameDay(e.dateTime, _selectedDate))
      .toList()
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  // Итоги за выбранную дату
  double get totalCalories => entriesForSelectedDate.fold(0.0, (s, e) => s + e.calories);
  double get totalProtein  => entriesForSelectedDate.fold(0.0, (s, e) => s + e.protein);
  double get totalFat      => entriesForSelectedDate.fold(0.0, (s, e) => s + e.fat);
  double get totalCarbs    => entriesForSelectedDate.fold(0.0, (s, e) => s + e.carbs);

  // Остатки до цели (не отрицательные)
  double _rem(double goal, double total) => max(0, goal - total);
  double get remCalories => _rem(goals.calories, totalCalories);
  double get remProtein  => _rem(goals.protein, totalProtein);
  double get remFat      => _rem(goals.fat, totalFat);
  double get remCarbs    => _rem(goals.carbs, totalCarbs);

  Future<void> addEntry(FoodEntry entry) async {
    _entries.add(entry);
    await _storage.saveEntries(_entries);
    notifyListeners();
  }

  Future<void> updateEntry(FoodEntry entry) async {
    final idx = _entries.indexWhere((e) => e.id == entry.id);
    if (idx != -1) {
      _entries[idx] = entry;
      await _storage.saveEntries(_entries);
      notifyListeners();
    }
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _storage.saveEntries(_entries);
    notifyListeners();
  }

  Future<void> setGoals(Goals g) async {
    _goals = g;
    await _storage.saveGoals(g);
    notifyListeners();
  }
}
