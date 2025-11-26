import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kbju_tracker/models/food_entry.dart';
import 'package:kbju_tracker/models/enums.dart';
import 'package:kbju_tracker/providers/tracker_provider.dart';

class AddEditEntryPage extends StatefulWidget {
  final FoodEntry? existing;
  const AddEditEntryPage({super.key, this.existing});

  @override
  State<AddEditEntryPage> createState() => _AddEditEntryPageState();
}

class _AddEditEntryPageState extends State<AddEditEntryPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameC = TextEditingController();
  final _calC = TextEditingController();
  final _proteinC = TextEditingController();
  final _fatC = TextEditingController();
  final _carbsC = TextEditingController();

  late DateTime _when;
  MealType _meal = MealType.snack;
  bool _autoCalc = true;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _nameC.text = e.name;
      _calC.text = e.calories.toStringAsFixed(0);
      _proteinC.text = e.protein.toStringAsFixed(0);
      _fatC.text = e.fat.toStringAsFixed(0);
      _carbsC.text = e.carbs.toStringAsFixed(0);
      _when = e.dateTime;
      _meal = e.meal;
      _autoCalc = (_calcCalories().round() == e.calories.round());
    } else {
      _when = DateTime.now();
      _meal = MealType.snack;
      _autoCalc = true;
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _calC.dispose();
    _proteinC.dispose();
    _fatC.dispose();
    _carbsC.dispose();
    super.dispose();
  }

  double _getDouble(String s) {
    if (s.trim().isEmpty) return 0.0;
    return double.tryParse(s.replaceAll(',', '.')) ?? 0.0;
  }

  double _calcCalories() {
    final p = _getDouble(_proteinC.text);
    final f = _getDouble(_fatC.text);
    final c = _getDouble(_carbsC.text);
    return p * 4.0 + f * 9.0 + c * 4.0;
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _when = DateTime(picked.year, picked.month, picked.day, _when.hour, _when.minute);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when),
    );
    if (picked != null) {
      setState(() {
        _when = DateTime(_when.year, _when.month, _when.day, picked.hour, picked.minute);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<TrackerProvider>();

    final calories = _autoCalc ? _calcCalories() : _getDouble(_calC.text);

    final entry = FoodEntry(
      id: widget.existing?.id ?? FoodEntry.generateId(),
      dateTime: _when,
      name: _nameC.text.trim(),
      calories: calories,
      protein: _getDouble(_proteinC.text),
      fat: _getDouble(_fatC.text),
      carbs: _getDouble(_carbsC.text),
      meal: _meal,
    );

    if (isEdit) {
      await provider.updateEntry(entry);
    } else {
      await provider.addEntry(entry);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final e = widget.existing;
    if (e == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить запись?'),
        content: Text(e.name),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await context.read<TrackerProvider>().deleteEntry(e.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isEdit ? 'Редактировать запись' : 'Новая запись';

    // синхронизация поля ккал при автоподсчёте
    if (_autoCalc) {
      final calculated = _calcCalories().toStringAsFixed(0);
      if (_calC.text != calculated) {
        _calC.text = calculated;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (isEdit)
            IconButton(
              tooltip: 'Удалить',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
          IconButton(
            tooltip: 'Сохранить',
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Название
              TextFormField(
                controller: _nameC,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите название' : null,
              ),
              const SizedBox(height: 16),

              // Приём пищи
              DropdownButtonFormField<MealType>(
                value: _meal,
                decoration: const InputDecoration(
                  labelText: 'Приём пищи',
                  border: OutlineInputBorder(),
                ),
                items: MealType.values
                    .map((m) => DropdownMenuItem<MealType>(
                  value: m,
                  child: Text(mealLabel(m)),
                ))
                    .toList(),
                onChanged: (v) => setState(() => _meal = v!),
              ),
              const SizedBox(height: 16),

              // Дата/время
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.event),
                      label: Text(_fmtDate(_when)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(_fmtTime(_when)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // БЖУ
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _proteinC,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Белки, г',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _fatC,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Жиры, г',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _carbsC,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Углев., г',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Ккал + переключатель автоподсчёта
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _calC,
                      enabled: !_autoCalc,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Калории, ккал',
                        border: OutlineInputBorder(),
                      ),
                      validator: (_) {
                        if (_autoCalc) return null;
                        final v = _getDouble(_calC.text);
                        return (v <= 0) ? 'Введите ккал' : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: CheckboxListTile(
                      value: _autoCalc,
                      onChanged: (v) => setState(() => _autoCalc = v ?? true),
                      title: const Text('Авто'),
                      subtitle: const Text('ккал из БЖУ'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
