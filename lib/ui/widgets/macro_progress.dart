import 'package:flutter/material.dart';

class MacroProgress extends StatelessWidget {
  final String label;
  final double value; // текущий итог
  final double goal;  // цель

  const MacroProgress({
    super.key,
    required this.label,
    required this.value,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (goal > 0) ? (value / goal).clamp(0.0, 1.0) : 0.0;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: theme.textTheme.labelLarge),
            const Spacer(),
            Text(
              goal > 0
                  ? '${value.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)}'
                  : value.toStringAsFixed(0),
              style: theme.textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: goal > 0 ? ratio : null, minHeight: 10),
        ),
      ],
    );
  }
}
