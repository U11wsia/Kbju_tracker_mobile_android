import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kbju_tracker/providers/settings_provider.dart';
import 'package:kbju_tracker/models/app_settings.dart';
import 'package:kbju_tracker/models/enums.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, s, _) {
        if (!s.isReady) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final AppSettings st = s.settings;

        return Scaffold(
          appBar: AppBar(title: const Text('Настройки')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: const Text('Тема'),
                subtitle: Text(st.themeMode.name),
                trailing: DropdownButton<ThemeMode>(
                  value: st.themeMode,
                  onChanged: (v) {
                    if (v == null) return;
                    s.saveSettings(st.copyWith(themeMode: v));
                  },
                  items: ThemeMode.values
                      .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                      .toList(),
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Единицы энергии'),
                subtitle: Text(st.energyUnit == EnergyUnit.kJ ? 'кДж' : 'ккал'),
                trailing: DropdownButton<EnergyUnit>(
                  value: st.energyUnit,
                  onChanged: (v) {
                    if (v == null) return;
                    s.saveSettings(st.copyWith(energyUnit: v));
                  },
                  items: EnergyUnit.values
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e == EnergyUnit.kJ ? 'кДж' : 'ккал'),
                  ))
                      .toList(),
                ),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Адаптивные цели по профилю'),
                subtitle: const Text('Рассчитывать цели из веса/активности/цели'),
                value: st.useAdaptiveGoals,
                onChanged: (v) => s.saveSettings(st.copyWith(useAdaptiveGoals: v)),
              ),
            ],
          ),
        );
      },
    );
  }
}
