import 'package:flutter/material.dart';
import '../../models/food_entry.dart';
import '../../models/enums.dart';

class EntryTile extends StatelessWidget {
  final FoodEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool useKJ; // NEW

  const EntryTile({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
    this.useKJ = false,
  });

  @override
  Widget build(BuildContext context) {
    final energy = useKJ ? entry.calories * 4.184 : entry.calories;
    final energyLabel = useKJ ? 'кДж' : 'ккал';

    final subtitle =
        'Энергия: ${energy.toStringAsFixed(0)} $energyLabel  •  '
        'Б: ${entry.protein.toStringAsFixed(0)} г  •  '
        'Ж: ${entry.fat.toStringAsFixed(0)} г  •  '
        'У: ${entry.carbs.toStringAsFixed(0)} г';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      title: Text('${entry.name} — ${mealLabel(entry.meal)}', maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle),
      trailing: PopupMenuButton<String>(
        onSelected: (v) {
          if (v == 'edit') onEdit();
          if (v == 'delete') onDelete();
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'edit', child: Text('Редактировать')),
          PopupMenuItem(
            value: 'delete',
            child: Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      onTap: onEdit,
    );
  }
}
