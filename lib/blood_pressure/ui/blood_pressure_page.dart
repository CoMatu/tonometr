import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:tonometr/blood_pressure/ui/dialogs/add_measurement_dialog.dart';
import 'package:tonometr/core/initialization/data/dependencies_ext.dart';
import 'package:tonometr/database/db.dart';
import 'package:tonometr/blood_pressure/domain/blood_pressure_repository.dart';

@RoutePage()
class BloodPressurePage extends StatefulWidget {
  const BloodPressurePage({super.key});

  @override
  State<BloodPressurePage> createState() => _BloodPressurePageState();
}

class _BloodPressurePageState extends State<BloodPressurePage> {
  List<Measurement> _measurements = [];
  bool _isLoading = true;
  bool _showFab = true;
  late final BloodPressureRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = context.dependencies.bloodPressureRepository;
    _loadMeasurements();
  }

  Future<void> _loadMeasurements() async {
    setState(() => _isLoading = true);
    try {
      final measurements = await _repository.getAllMeasurements();
      // Сортируем по дате создания - самые новые вверху
      measurements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
          (context) => AddMeasurementDialog(
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
                      leading: BloodPressureCategoryIndicator(
                        systolic: measurement.systolic,
                        diastolic: measurement.diastolic,
                      ),
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
        await _repository.deleteMeasurement(measurement);
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

class BloodPressureCategoryIndicator extends StatelessWidget {
  final int systolic;
  final int diastolic;
  const BloodPressureCategoryIndicator({
    super.key,
    required this.systolic,
    required this.diastolic,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(systolic, diastolic);
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

Color _getCategoryColor(int systolic, int diastolic) {
  if (systolic >= 160 || diastolic >= 100) {
    return Colors.red;
  } else if (systolic >= 140 || diastolic >= 90) {
    return Colors.orange;
  } else if (systolic >= 130 || diastolic >= 85) {
    return Colors.amber;
  } else {
    return Colors.green;
  }
}
