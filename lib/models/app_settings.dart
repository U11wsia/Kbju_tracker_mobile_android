import 'package:flutter/material.dart';
import 'enums.dart';

class AppSettings {
  final EnergyUnit energyUnit;
  final ThemeMode themeMode;
  final bool useAdaptiveGoals; // true = считать цели по профилю; false = ручные

  const AppSettings({
    required this.energyUnit,
    required this.themeMode,
    required this.useAdaptiveGoals,
  });

  AppSettings copyWith({
    EnergyUnit? energyUnit,
    ThemeMode? themeMode,
    bool? useAdaptiveGoals,
  }) => AppSettings(
    energyUnit: energyUnit ?? this.energyUnit,
    themeMode: themeMode ?? this.themeMode,
    useAdaptiveGoals: useAdaptiveGoals ?? this.useAdaptiveGoals,
  );

  Map<String, dynamic> toJson() => {
    'energyUnit': energyUnit.name,
    'themeMode': themeMode.name,
    'useAdaptiveGoals': useAdaptiveGoals,
  };

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
    energyUnit: EnergyUnit.values.firstWhere((e) => e.name == j['energyUnit']),
    themeMode: ThemeMode.values.firstWhere((e) => e.name == j['themeMode']),
    useAdaptiveGoals: j['useAdaptiveGoals'] as bool,
  );

  static const AppSettings defaults = AppSettings(
    energyUnit: EnergyUnit.kcal,
    themeMode: ThemeMode.system,
    useAdaptiveGoals: true,
  );
}
