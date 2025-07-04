import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:tonometr/blood_pressure/ui/cards/blood_pressure_card.dart';
import 'package:tonometr/blood_pressure/ui/dialogs/add_measurement_dialog.dart';
import 'package:tonometr/core/initialization/data/dependencies_ext.dart';
import 'package:tonometr/database/db.dart';
import 'package:tonometr/blood_pressure/domain/blood_pressure_repository.dart';
import 'package:tonometr/core/services/event_bus.dart';

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
  StreamSubscription<DataChangedEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _repository = context.dependencies.bloodPressureRepository;
    _loadMeasurements();
    _subscribeToEvents();
  }

  void _subscribeToEvents() {
    _eventSubscription = EventBus().on<DataChangedEvent>().listen((event) {
      if (event.dataType == 'measurements' && mounted) {
        _loadMeasurements();
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
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
                  return BloodPressureCard(
                    measurement: measurement,
                    onDelete: () => _deleteMeasurement(measurement),
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
        EventBus().emit(DataChangedEvent('measurements'));
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
