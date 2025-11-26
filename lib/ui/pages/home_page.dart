import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kbju_tracker/models/food_entry.dart';
import 'package:kbju_tracker/models/goals.dart';
import 'package:kbju_tracker/models/enums.dart';
import 'package:kbju_tracker/providers/tracker_provider.dart';
import 'package:kbju_tracker/providers/settings_provider.dart';
import 'package:kbju_tracker/ui/widgets/macro_progress.dart';
import 'package:kbju_tracker/ui/widgets/entry_tile.dart';
import 'package:kbju_tracker/ui/pages/add_edit_entry_page.dart';
import 'package:kbju_tracker/ui/pages/settings_page.dart' show SettingsPage;
import 'package:kbju_tracker/ui/pages/onboarding_page.dart' show OnboardingPage;


// Импортируем ТОЛЬКО класс страницы настроек (чтобы не тянуть ничего лишнего)
import 'package:kbju_tracker/ui/pages/settings_page.dart' show SettingsPage;
// Онбординг как отдельная страница
import 'package:kbju_tracker/ui/pages/onboarding_page.dart' show OnboardingPage;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Consumer2<TrackerProvider, SettingsProvider>(
        // Явно типизируем параметры, чтобы не было Object?/nullable
        builder: (BuildContext context, TrackerProvider t, SettingsProvider s, _) {
          if (!t.isReady || !s.isReady) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Если профиль не заполнен — показываем онбординг
          if (!s.isOnboarded) {
            return const _OnboardingGate();
          }

          final bool useKJ = s.settings.energyUnit == EnergyUnit.kJ;
          final Goals effectiveGoals =
          s.settings.useAdaptiveGoals ? s.computeAdaptiveGoals() : t.goals;

          return Scaffold(
            appBar: AppBar(
              title: const Text('KБЖУ-Трекер'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Сегодня'),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Календарь',
                  icon: const Icon(Icons.event),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: t.selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) t.setSelectedDate(picked);
                  },
                ),
                IconButton(
                  tooltip: 'Настройки',
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddEditEntryPage()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Добавить'),
            ),
            body: TabBarView(
              children: [
                _TodayView(useKJ: useKJ, effectiveGoals: effectiveGoals),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Онбординг внутри Home, если профиль пустой
class _OnboardingGate extends StatelessWidget {
  const _OnboardingGate();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OnboardingPage()),
            );
          },
          child: const Text('Заполнить профиль'),
        ),
      ),
    );
  }
}

class _TodayView extends StatelessWidget {
  final bool useKJ;
  final Goals effectiveGoals;
  const _TodayView({required this.useKJ, required this.effectiveGoals});

  String _dateLabel(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackerProvider>(
      builder: (context, t, _) {
        final today = DateTime.now();
        final isToday = _sameDay(t.selectedDate, today);

        // Итоги/единицы
        final double calValue = useKJ ? (t.totalCalories * 4.184) : t.totalCalories;
        final double calGoal = useKJ
            ? (effectiveGoals.calories * 4.184)
            : effectiveGoals.calories;
        final String calLabel = useKJ ? 'Энергия, кДж' : 'Калории, ккал';

        // Группировка по приёмам пищи
        final Map<MealType, List<FoodEntry>> grouped = {
          for (final m in MealType.values) m: <FoodEntry>[],
        };
        for (final e in t.entriesForSelectedDate) {
          grouped[e.meal]?.add(e);
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Предыдущий день',
                    onPressed: () => t.setSelectedDate(
                      t.selectedDate.subtract(const Duration(days: 1)),
                    ),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        isToday
                            ? 'Сегодня • ${_dateLabel(t.selectedDate)}'
                            : _dateLabel(t.selectedDate),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Следующий день',
                    onPressed: isToday
                        ? null
                        : () => t.setSelectedDate(
                      t.selectedDate.add(const Duration(days: 1)),
                    ),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  MacroProgress(label: calLabel, value: calValue, goal: calGoal),
                  const SizedBox(height: 12),
                  MacroProgress(
                      label: 'Белки, г',
                      value: t.totalProtein,
                      goal: effectiveGoals.protein),
                  const SizedBox(height: 12),
                  MacroProgress(
                      label: 'Жиры, г',
                      value: t.totalFat,
                      goal: effectiveGoals.fat),
                  const SizedBox(height: 12),
                  MacroProgress(
                      label: 'Углев., г',
                      value: t.totalCarbs,
                      goal: effectiveGoals.carbs),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
            Expanded(
              child: Builder(
                builder: (_) {
                  final allEmpty = grouped.values.every((l) => l.isEmpty);
                  if (allEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Записей за этот день пока нет.\nНажмите «Добавить», чтобы создать первую запись.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 88, top: 8),
                    children: MealType.values.expand((m) {
                      final list = grouped[m]!..sort(
                            (a, b) => b.dateTime.compareTo(a.dateTime),
                      );
                      if (list.isEmpty) return <Widget>[];
                      return [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: Text(
                            mealLabel(m),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        ...list.map((e) => _swipeableTile(context, e, useKJ)),
                        const Divider(height: 16),
                      ];
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _swipeableTile(BuildContext context, FoodEntry e, bool useKJ) {
    final t = context.read<TrackerProvider>();
    return Dismissible(
      key: ValueKey('entry_${e.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        color: Colors.blueGrey,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: const Row(
          children: [
            Icon(Icons.edit, color: Colors.white),
            SizedBox(width: 8),
            Text('Редакт./Дублир.', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Удалить', style: TextStyle(color: Colors.white)),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.endToStart) {
          // Влево — удаление
          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Удалить запись?'),
              content: Text(e.name),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Отмена')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Удалить',
                        style: TextStyle(color: Colors.red))),
              ],
            ),
          );
          if (ok == true) {
            await t.deleteEntry(e.id);
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Удалено')));
            return true;
          }
          return false;
        } else {
          // Вправо — быстрые действия
          final action = await showModalBottomSheet<String>(
            context: context,
            builder: (_) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Редактировать'),
                    onTap: () => Navigator.pop(context, 'edit'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.copy),
                    title: const Text('Дублировать'),
                    onTap: () => Navigator.pop(context, 'dup'),
                  ),
                ],
              ),
            ),
          );
          if (action == 'edit') {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AddEditEntryPage(existing: e)),
            );
            return false;
          } else if (action == 'dup') {
            final copy =
            e.copyWith(id: FoodEntry.generateId(), dateTime: DateTime.now());
            await t.addEntry(copy);
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Дубликат добавлен')));
            return false;
          }
          return false;
        }
      },
      child: EntryTile(
        entry: e,
        useKJ: useKJ,
        onEdit: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AddEditEntryPage(existing: e)),
        ),
        onDelete: () async {
          await t.deleteEntry(e.id);
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Удалено')));
        },
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
