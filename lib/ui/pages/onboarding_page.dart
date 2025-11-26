import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/enums.dart';
import '../../../models/user_profile.dart';
import '../../../models/app_settings.dart';
import '../../../providers/settings_provider.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  Sex _sex = Sex.male;
  ActivityLevel _activity = ActivityLevel.sedentary;
  GoalType _goal = GoalType.maintain;

  final _wC = TextEditingController();
  final _hC = TextEditingController();

  @override
  void dispose() {
    _wC.dispose();
    _hC.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) {
    return double.tryParse(c.text.trim().replaceAll(',', '.')) ?? 0;
  }

  void _finish() async {
    final weight = _parse(_wC);
    final height = _parse(_hC);
    if (weight <= 0 || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Укажите вес и рост.')));
      return;
    }
    final profile = UserProfile(
      sex: _sex,
      weightKg: weight,
      heightCm: height,
      activity: _activity,
      goal: _goal,
    );
    final sp = context.read<SettingsProvider>();
    await sp.saveProfile(profile);

    // включим адаптивные цели по умолчанию
    await sp.saveSettings(sp.settings.copyWith(useAdaptiveGoals: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добро пожаловать')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Расскажите немного о себе — это нужно для расчёта целей.'),
            const SizedBox(height: 16),

            const Text('Пол'),
            const SizedBox(height: 8),
            SegmentedButton<Sex>(
              segments: const [
                ButtonSegment(value: Sex.male, label: Text('М')),
                ButtonSegment(value: Sex.female, label: Text('Ж')),
              ],
              selected: {_sex},
              onSelectionChanged: (s) => setState(() => _sex = s.first),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _numField(_wC, 'Вес, кг')),
                const SizedBox(width: 12),
                Expanded(child: _numField(_hC, 'Рост, см')),
              ],
            ),
            const SizedBox(height: 16),

            const Text('Активность'),
            const SizedBox(height: 8),
            DropdownButton<ActivityLevel>(
              isExpanded: true,
              value: _activity,
              onChanged: (v) => setState(() => _activity = v!),
              items: const [
                DropdownMenuItem(value: ActivityLevel.sedentary, child: Text('Сидячий')),
                DropdownMenuItem(value: ActivityLevel.light,     child: Text('Лёгкая')),
                DropdownMenuItem(value: ActivityLevel.moderate,  child: Text('Средняя')),
                DropdownMenuItem(value: ActivityLevel.high,      child: Text('Высокая')),
              ],
            ),
            const SizedBox(height: 16),

            const Text('Цель'),
            const SizedBox(height: 8),
            DropdownButton<GoalType>(
              isExpanded: true,
              value: _goal,
              onChanged: (v) => setState(() => _goal = v!),
              items: const [
                DropdownMenuItem(value: GoalType.lose,     child: Text('Сушка / минус вес')),
                DropdownMenuItem(value: GoalType.maintain, child: Text('Поддержание')),
                DropdownMenuItem(value: GoalType.gain,     child: Text('Набор')),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () { _finish(); Navigator.of(context).maybePop(); },
              child: const Text('Сохранить и начать'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numField(TextEditingController c, String label) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }
}
