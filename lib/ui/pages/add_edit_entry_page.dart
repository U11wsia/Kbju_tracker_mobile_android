import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food_entry.dart';
import '../../providers/tracker_provider.dart';

class AddEditEntryPage extends StatefulWidget {
  final FoodEntry? existing;

  const AddEditEntryPage({super.key, this.existing});

  @override
  State<AddEditEntryPage> createState() => _AddEditEntryPageState();
}

class _AddEditEntryPageState extends State<AddEditEntryPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameC;
  late final TextEditingController _proteinC;
  late final TextEditingController _fatC;
  late final TextEditingController _carbsC;
  late final TextEditingController _calC;
  late DateTime _when;
  bool _autoCalc = true;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameC = TextEditingController(text: e?.name ?? '');
    _proteinC = TextEditingController(text: _fmt(e?.protein));
    _fatC = TextEditingController(text: _fmt(e?.fat));
    _carbsC = TextEditingController(text: _fmt(e?.carbs));
    _calC = TextEditingController(text: _fmt(e?.calories));
    _when = e?.dateTime ?? DateTime.now();
    _autoCalc = e == null ? true : _isClose(_calcCalories(), _getDouble(_calC.text));
    _wireAutoCalc();
  }

  String _fmt(double? v) => (v == null || v == 0) ? '' : v.toStringAsFixed(0);

  double _getDouble(String s) {
    final t = s.trim().replaceAll(',', '.');
    return double.tryParse(t) ?? 0.0;
  }

  double _calcCalories() {
    final p = _getDouble(_proteinC.text);
    final f = _getDouble(_fatC.text);
    final c = _getDouble(_carbsC.text);
    return 4 * p + 9 * f + 4 * c;
  }

  bool _isClose(double a, double b) => (a - b).abs() < 1.0;

  void _wireAutoCalc() {
    void recalc() {
      if (!_autoCalc) return;
      final kcal = _calcCalories();
      _calC.value = _calC.value.copyWith(
        text: kcal.toStringAsFixed(0),
        selection: TextSelection.collapsed(offset: kcal.toStringAsFixed(0).length),
      );
      setState(() {});
    }
    _proteinC.addListener(recalc);
    _fatC.addListener(recalc);
    _carbsC.addListener(recalc);
    if (_autoCalc) recalc();
  }

  @override
  void dispose() {
    _nameC.dispose();
    _proteinC.dispose();
    _fatC.dispose();
    _carbsC.dispose();
    _calC.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final datePicked = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (datePicked == null) return;
    final timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when),
    );
    final time = timePicked ?? TimeOfDay.fromDateTime(_when);
    setState(() {
      _when = DateTime(datePicked.year, datePicked.month, datePicked.day, time.hour, time.minute);
    });
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<TrackerProvider>();
    final entry = FoodEntry(
      id: widget.existing?.id ?? FoodEntry.generateId(),
      dateTime: _when,
      name: _nameC.text.trim(),
      calories: _getDouble(_calC.text == '' && _autoCalc ? _calcCalories().toString() : _calC.text),
      protein: _getDouble(_proteinC.text),
      fat: _getDouble(_fatC.text),
      carbs: _getDouble(_carbsC.text),
    );

    if (widget.existing == null) {
      await provider.addEntry(entry);
    } else {
      await provider.updateEntry(entry);
    }
    if (mounted) Navigator.of(context).pop();
  }

  String _dateLabel(DateTime dt) {
    final d = '${_pad(dt.day)}.${_pad(dt.month)}.${dt.year}';
    final t = '${_pad(dt.hour)}:${_pad(dt.minute)}';
    return '$d  •  $t';
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Редактировать запись' : 'Новая запись'),
        actions: [
          if (isEdit)
            IconButton(
              tooltip: 'Удалить',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Удалить запись?'),
                    content: const Text('Это действие нельзя отменить.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await context.read<TrackerProvider>().deleteEntry(widget.existing!.id);
                  if (mounted) Navigator.of(context).pop();
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameC,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Название продукта / блюда',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Укажите название' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _numField(controller: _proteinC, label: 'Белки, г')),
                  const SizedBox(width: 12),
                  Expanded(child: _numField(controller: _fatC, label: 'Жиры, г')),
                  const SizedBox(width: 12),
                  Expanded(child: _numField(controller: _carbsC, label: 'Углеводы, г')),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Считать калории по БЖУ автоматически'),
                value: _autoCalc,
                onChanged: (v) => setState(() => _autoCalc = v),
              ),
              const SizedBox(height: 8),
              _numField(
                controller: _calC,
                label: 'Калории, ккал',
                enabled: !_autoCalc,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: const Text('Дата и время'),
                subtitle: Text(_dateLabel(_when)),
                trailing: TextButton(
                  onPressed: _pickDateTime,
                  child: const Text('Изменить'),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: Text(isEdit ? 'Сохранить изменения' : 'Добавить'),
              ),
              const SizedBox(height: 24),
              Text(
                'Подсказка: если оставить поле «Калории» пустым и включить автоподсчёт — ккал вычислятся из БЖУ.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _numField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (!enabled) return null;
        final s = (v ?? '').trim();
        if (s.isEmpty) return null; // можно не заполнять
        final n = double.tryParse(s.replaceAll(',', '.'));
        if (n == null || n < 0) return 'Некорректное число';
        return null;
      },
    );
  }
}
