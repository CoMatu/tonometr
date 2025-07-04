import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:tonometr/blood_pressure/domain/blood_pressure_repository.dart';
import 'package:tonometr/charts/data/chart_data_service.dart';
import 'package:tonometr/charts/ui/widgets/blood_pressure_chart.dart';
import 'package:tonometr/charts/ui/widgets/chart_legend.dart';
import 'package:tonometr/charts/ui/widgets/period_selector.dart';
import 'package:tonometr/charts/ui/dialogs/custom_period_dialog.dart';
import 'package:tonometr/core/initialization/data/dependencies_ext.dart';
import 'package:tonometr/core/services/event_bus.dart';
import 'package:tonometr/database/db.dart';

@RoutePage()
class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  List<Measurement> _allMeasurements = [];
  List<Measurement> _filteredMeasurements = [];
  ChartPeriod _selectedPeriod = ChartPeriod.week;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  bool _isLoading = true;
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
      // Сортируем по дате создания - от старых к новым
      measurements.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      setState(() {
        _allMeasurements = measurements;
        _isLoading = false;
      });
      _filterMeasurements();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка загрузки данных: $e')));
      }
    }
  }

  void _filterMeasurements() {
    final filtered = ChartDataService.filterMeasurementsByPeriod(
      _allMeasurements,
      _selectedPeriod,
      _customStartDate,
      _customEndDate,
    );
    setState(() {
      _filteredMeasurements = filtered;
    });
  }

  void _onPeriodChanged(ChartPeriod period) {
    setState(() {
      _selectedPeriod = period;
      if (period != ChartPeriod.custom) {
        _customStartDate = null;
        _customEndDate = null;
      }
    });
    _filterMeasurements();
  }

  void _showCustomPeriodDialog() async {
    final result = await showDialog<Map<String, DateTime>>(
      context: context,
      builder:
          (context) => CustomPeriodDialog(
            initialStartDate: _customStartDate,
            initialEndDate: _customEndDate,
          ),
    );

    if (result != null) {
      setState(() {
        _selectedPeriod = ChartPeriod.custom;
        _customStartDate = result['startDate'];
        _customEndDate = result['endDate'];
      });
      _filterMeasurements();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('График давления')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  PeriodSelector(
                    selectedPeriod: _selectedPeriod,
                    onPeriodChanged: _onPeriodChanged,
                    onCustomPeriodPressed: _showCustomPeriodDialog,
                  ),
                  const ChartLegend(),
                  Expanded(
                    child: BloodPressureChart(
                      measurements: _filteredMeasurements,
                      period: _selectedPeriod,
                    ),
                  ),
                ],
              ),
    );
  }
}
