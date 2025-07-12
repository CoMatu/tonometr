import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:tonometr/blood_pressure/domain/blood_pressure_repository.dart';
import 'package:tonometr/charts/data/chart_data_service.dart';
import 'package:tonometr/charts/ui/widgets/blood_pressure_chart.dart';
import 'package:tonometr/charts/ui/widgets/chart_legend.dart';
import 'package:tonometr/charts/ui/widgets/period_selector.dart';
import 'package:tonometr/charts/ui/dialogs/custom_period_dialog.dart';
import 'package:tonometr/config/app_config.dart';
import 'package:tonometr/core/initialization/data/dependencies_ext.dart';
import 'package:tonometr/core/services/event_bus.dart';
import 'package:tonometr/core/ui_kit/show_top_snackbar.dart';
import 'package:tonometr/core/ui_kit/yandex_banner_ad_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        showTopSnackBar(
          context: context,
          message: 'Ошибка загрузки данных: $e',
          type: TopSnackBarType.error,
        );
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

  Future<void> _initAdsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_adsKey);
    setState(() {
      _adsEnabled = value != 'false';
      _adsLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('График давления'), toolbarHeight: 48),
      body: Column(
        children: [
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: PeriodSelector(
                            selectedPeriod: _selectedPeriod,
                            onPeriodChanged: _onPeriodChanged,
                            onCustomPeriodPressed: _showCustomPeriodDialog,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: const ChartLegend(),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: BloodPressureChart(
                              measurements: _filteredMeasurements,
                              period: _selectedPeriod,
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
          if (!_adsLoading && _adsEnabled)
            YandexBannerAdWidget(adUnitId: AppConfig.yandexBannerAdId),
        ],
      ),
    );
  }
}
