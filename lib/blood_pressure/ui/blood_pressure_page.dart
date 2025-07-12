import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:tonometr/blood_pressure/ui/cards/blood_pressure_card.dart';
import 'package:tonometr/blood_pressure/ui/dialogs/add_measurement_dialog.dart';
import 'package:tonometr/core/initialization/data/dependencies_ext.dart';
import 'package:tonometr/core/ui_kit/show_top_snackbar.dart';
import 'package:tonometr/database/db.dart';
import 'package:tonometr/blood_pressure/domain/blood_pressure_repository.dart';
import 'package:tonometr/core/services/event_bus.dart';
import 'package:tonometr/core/ui_kit/yandex_banner_ad_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TODO(CoMatu): Добавить пагинацию списка измерений
// Matusevich Vyacheslav <Telegram: @CoMatu>, 05 July 2025

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
  bool _adsEnabled = true;
  bool _adsLoading = true;
  final _adsKey = 'ads_enabled';

  @override
  void initState() {
    super.initState();
    _repository = context.dependencies.bloodPressureRepository;
    _loadMeasurements();
    _subscribeToEvents();
    _initAdsEnabled();
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
        showTopSnackBar(
          context: context,
          message: 'Ошибка загрузки данных: $e',
          type: TopSnackBarType.error,
        );
      }
    }
  }

  Future<void> _initAdsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_adsKey);
    setState(() {
      _adsEnabled = value != 'false';
      _adsLoading = false;
    });
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

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('О конфиденциальности'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Конфиденциальность данных',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  '• Приложение не собирает и не хранит персональные данные',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  '• Все данные сохраняются только в памяти устройства',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  '• Данные не передаются на внешние серверы',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  '• Вы полностью контролируете свои данные',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Понятно'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Давление'),
        actions: [
          IconButton(
            onPressed: _showPrivacyDialog,
            icon: const Icon(Icons.help_outline),
            tooltip: 'Справка',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
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
          ),
          if (!_adsLoading && _adsEnabled)
            const YandexBannerAdWidget(adUnitId: 'R-M-16235352-1'),
        ],
      ),
      floatingActionButton:
          _showFab
              ? FloatingActionButton(
                backgroundColor: Colors.orange,
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
          showTopSnackBar(
            context: context,
            message: 'Запись удалена',
            type: TopSnackBarType.success,
          );
        }
      } catch (e) {
        if (mounted) {
          showTopSnackBar(
            context: context,
            message: 'Ошибка удаления: $e',
            type: TopSnackBarType.error,
          );
        }
      }
    }
  }
}
