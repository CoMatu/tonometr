import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:tonometr/core/initialization/data/dependencies_ext.dart';
import 'package:tonometr/database/db.dart';

@RoutePage()
class BloodPressurePage extends StatefulWidget {
  const BloodPressurePage({super.key});

  @override
  State<BloodPressurePage> createState() => _BloodPressurePageState();
}

class _BloodPressurePageState extends State<BloodPressurePage> {
  List<Measurement> _measurements = [];
  bool _isLoading = true;
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
    // Показываем модальное окно при запуске
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAddMeasurementDialog();
    });
  }

  Future<void> _loadMeasurements() async {
    setState(() => _isLoading = true);
    try {
      final measurements =
          await context.dependencies.database.getAllMeasurements();
      setState(() {
        _measurements = measurements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка загрузки данных: $e')));
      }
    }
  }

  void _showAddMeasurementDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => _AddMeasurementDialog(
            onSaved: () {
              _loadMeasurements();
              setState(() => _showFab = true);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Давление')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _measurements.isEmpty
              ? const Center(
                child: Text(
                  'Нет записей о давлении',
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _measurements.length,
                itemBuilder: (context, index) {
                  final measurement = _measurements[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        '${measurement.systolic}/${measurement.diastolic} мм рт.ст.',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Пульс: ${measurement.pulse} уд/мин'),
                          if (measurement.note != null &&
                              measurement.note!.isNotEmpty)
                            Text('Заметка: ${measurement.note}'),
                          Text(
                            _formatDate(measurement.createdAt),
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteMeasurement(measurement),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton:
          _showFab
              ? FloatingActionButton(
                onPressed: _showAddMeasurementDialog,
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final measurementDate = DateTime(date.year, date.month, date.day);

    if (measurementDate == today) {
      return 'Сегодня в ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (measurementDate == today.subtract(const Duration(days: 1))) {
      return 'Вчера в ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} в ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _deleteMeasurement(Measurement measurement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Удалить запись?'),
            content: const Text('Это действие нельзя отменить.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Удалить'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await context.dependencies.database.deleteMeasurement(measurement);
        await _loadMeasurements();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Запись удалена')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Ошибка удаления: $e')));
        }
      }
    }
  }
}

class _AddMeasurementDialog extends StatefulWidget {
  final VoidCallback onSaved;

  const _AddMeasurementDialog({required this.onSaved});

  @override
  State<_AddMeasurementDialog> createState() => _AddMeasurementDialogState();
}

class _AddMeasurementDialogState extends State<_AddMeasurementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _pulseController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSaving = false;

  static const _fieldWidth = 300.0;

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _pulseController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveMeasurement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final systolic = int.parse(_systolicController.text);
      final diastolic = int.parse(_diastolicController.text);
      final pulse = int.parse(_pulseController.text);
      final note = _noteController.text.isEmpty ? null : _noteController.text;

      await context.dependencies.database.addMeasurement(
        MeasurementsCompanion.insert(
          systolic: systolic,
          diastolic: diastolic,
          pulse: pulse,
          note: Value(note),
        ),
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSaved();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Данные сохранены')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка сохранения: $e')));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Новое измерение',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: _fieldWidth,
              child: TextFormField(
                controller: _systolicController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Систолическое давление',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите систолическое давление';
                  }
                  final systolic = int.tryParse(value);
                  if (systolic == null || systolic <= 0) {
                    return 'Введите корректное значение';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: _fieldWidth,
              child: TextFormField(
                controller: _diastolicController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Диастолическое давление',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите диастолическое давление';
                  }
                  final diastolic = int.tryParse(value);
                  if (diastolic == null || diastolic <= 0) {
                    return 'Введите корректное значение';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: _fieldWidth,
              child: TextFormField(
                controller: _pulseController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(labelText: 'Пульс'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите пульс';
                  }
                  final pulse = int.tryParse(value);
                  if (pulse == null || pulse <= 0) {
                    return 'Введите корректное значение';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: _fieldWidth,
              child: TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Заметка (необязательно)',
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed:
                        _isSaving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Отмена'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveMeasurement,
                    child:
                        _isSaving
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Сохранить'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
