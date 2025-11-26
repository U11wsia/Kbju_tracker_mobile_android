class Goals {
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  const Goals({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  Goals copyWith({
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
  }) {
    return Goals(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
    );
  }

  Map<String, dynamic> toJson() => {
    'calories': calories,
    'protein': protein,
    'fat': fat,
    'carbs': carbs,
  };

  factory Goals.fromJson(Map<String, dynamic> json) => Goals(
    calories: (json['calories'] as num).toDouble(),
    protein: (json['protein'] as num).toDouble(),
    fat: (json['fat'] as num).toDouble(),
    carbs: (json['carbs'] as num).toDouble(),
  );

  static const Goals defaults = Goals(
    calories: 2000,
    protein: 120,
    fat: 70,
    carbs: 250,
  );
}
