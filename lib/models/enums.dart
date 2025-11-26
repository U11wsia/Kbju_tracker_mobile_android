import 'package:flutter/material.dart';

enum Sex { male, female }
enum ActivityLevel { sedentary, light, moderate, high }
enum GoalType { lose, maintain, gain }
enum EnergyUnit { kcal, kJ }
enum MealType { breakfast, lunch, dinner, snack }

String mealLabel(MealType m) {
  switch (m) {
    case MealType.breakfast: return 'Завтрак';
    case MealType.lunch:     return 'Обед';
    case MealType.dinner:    return 'Ужин';
    case MealType.snack:     return 'Перекус';
  }
}
