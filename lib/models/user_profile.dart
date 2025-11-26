import 'enums.dart';

class UserProfile {
  final Sex sex;
  final double weightKg;
  final double heightCm;
  final ActivityLevel activity;
  final GoalType goal;

  const UserProfile({
    required this.sex,
    required this.weightKg,
    required this.heightCm,
    required this.activity,
    required this.goal,
  });

  Map<String, dynamic> toJson() => {
    'sex': sex.name,
    'weightKg': weightKg,
    'heightCm': heightCm,
    'activity': activity.name,
    'goal': goal.name,
  };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
    sex: Sex.values.firstWhere((e) => e.name == j['sex']),
    weightKg: (j['weightKg'] as num).toDouble(),
    heightCm: (j['heightCm'] as num).toDouble(),
    activity: ActivityLevel.values.firstWhere((e) => e.name == j['activity']),
    goal: GoalType.values.firstWhere((e) => e.name == j['goal']),
  );
}
