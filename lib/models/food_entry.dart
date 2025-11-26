import 'dart:math';
import 'enums.dart';

class FoodEntry {
  final String id;
  final DateTime dateTime;
  final String name;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final MealType meal; // NEW

  FoodEntry({
    required this.id,
    required this.dateTime,
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.meal = MealType.snack, // по умолчанию «перекус» для совместимости
  });

  FoodEntry copyWith({
    String? id,
    DateTime? dateTime,
    String? name,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
    MealType? meal,
  }) => FoodEntry(
    id: id ?? this.id,
    dateTime: dateTime ?? this.dateTime,
    name: name ?? this.name,
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    fat: fat ?? this.fat,
    carbs: carbs ?? this.carbs,
    meal: meal ?? this.meal,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'dateTime': dateTime.toIso8601String(),
    'name': name,
    'calories': calories,
    'protein': protein,
    'fat': fat,
    'carbs': carbs,
    'meal': meal.name,
  };

  factory FoodEntry.fromJson(Map<String, dynamic> json) => FoodEntry(
    id: json['id'] as String,
    dateTime: DateTime.parse(json['dateTime'] as String),
    name: json['name'] as String,
    calories: (json['calories'] as num).toDouble(),
    protein: (json['protein'] as num).toDouble(),
    fat: (json['fat'] as num).toDouble(),
    carbs: (json['carbs'] as num).toDouble(),
    meal: json['meal'] != null
        ? MealType.values.firstWhere((e) => e.name == json['meal'])
        : MealType.snack,
  );

  static String generateId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final rand = Random().nextInt(1 << 32);
    return '$now-$rand';
  }
}
