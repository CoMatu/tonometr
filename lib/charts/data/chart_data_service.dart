import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tonometr/database/db.dart';

enum ChartPeriod { week, month, custom }

class ChartDataService {
  static List<FlSpot> prepareSystolicData(List<Measurement> measurements) {
    return measurements
        .asMap()
        .entries
        .map(
          (entry) =>
              FlSpot(entry.key.toDouble(), entry.value.systolic.toDouble()),
        )
        .toList();
  }

  static List<FlSpot> prepareDiastolicData(List<Measurement> measurements) {
    return measurements
        .asMap()
        .entries
        .map(
          (entry) =>
              FlSpot(entry.key.toDouble(), entry.value.diastolic.toDouble()),
        )
        .toList();
  }

  static List<FlSpot> preparePulseData(List<Measurement> measurements) {
    return measurements
        .asMap()
        .entries
        .map(
          (entry) => FlSpot(entry.key.toDouble(), entry.value.pulse.toDouble()),
        )
        .toList();
  }

  static List<String> prepareXAxisLabels(List<Measurement> measurements) {
    return measurements.map((measurement) {
      final date = measurement.createdAt;
      final dayOfWeek = _getDayOfWeek(date.weekday);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final time = formatMeasurementTime(date);
      return '$day.$month\n$dayOfWeek\n$time';
    }).toList();
  }

  /// Возвращает список индексов подписей, которые должны отображаться на оси X
  static List<int> getVisibleLabelIndices(List<Measurement> measurements) {
    if (measurements.isEmpty) return [];

    final int totalCount = measurements.length;

    // Определяем количество подписей для отображения в зависимости от общего количества
    int visibleCount;
    if (totalCount <= 7) {
      // Для недели показываем все подписи
      visibleCount = totalCount;
    } else if (totalCount <= 14) {
      // Для 2 недель показываем каждую вторую
      visibleCount = (totalCount / 2).ceil();
    } else if (totalCount <= 30) {
      // Для месяца показываем каждую третью
      visibleCount = (totalCount / 3).ceil();
    } else if (totalCount <= 60) {
      // Для 2 месяцев показываем каждую четвертую
      visibleCount = (totalCount / 4).ceil();
    } else {
      // Для большего количества показываем максимум 8 подписей
      visibleCount = 8;
    }

    // Вычисляем шаг между подписями
    final int step =
        totalCount > visibleCount ? (totalCount / visibleCount).floor() : 1;

    // Создаем список индексов для отображения
    List<int> indices = [];
    for (int i = 0; i < totalCount; i += step) {
      indices.add(i);
      if (indices.length >= visibleCount) break;
    }

    // Всегда добавляем последний индекс, если его еще нет
    if (indices.isNotEmpty && indices.last != totalCount - 1) {
      indices.add(totalCount - 1);
    }

    // Убираем дубликаты и сортируем
    indices = indices.toSet().toList()..sort();

    return indices;
  }

  static String formatMeasurementTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'Пн';
      case 2:
        return 'Вт';
      case 3:
        return 'Ср';
      case 4:
        return 'Чт';
      case 5:
        return 'Пт';
      case 6:
        return 'Сб';
      case 7:
        return 'Вс';
      default:
        return '';
    }
  }

  static List<Measurement> filterMeasurementsByPeriod(
    List<Measurement> allMeasurements,
    ChartPeriod period,
    DateTime? customStartDate,
    DateTime? customEndDate,
  ) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case ChartPeriod.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case ChartPeriod.month:
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case ChartPeriod.custom:
        if (customStartDate != null && customEndDate != null) {
          return allMeasurements
              .where(
                (measurement) =>
                    measurement.createdAt.isAfter(
                      customStartDate.subtract(const Duration(days: 1)),
                    ) &&
                    measurement.createdAt.isBefore(
                      customEndDate.add(const Duration(days: 1)),
                    ),
              )
              .toList();
        }
        startDate = now.subtract(const Duration(days: 7));
        break;
    }

    return allMeasurements
        .where((measurement) => measurement.createdAt.isAfter(startDate))
        .toList();
  }

  static List<HorizontalLine> getHypertensionLines() {
    return [
      // Высокое давление (красная линия)
      HorizontalLine(
        y: 160,
        color: Colors.red.withValues(alpha: 0.5),
        strokeWidth: 1,
        dashArray: [5, 5],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topRight,
          padding: const EdgeInsets.only(right: 8, top: 4),
          style: TextStyle(
            color: Colors.red.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          labelResolver: (line) => '160',
        ),
      ),
      HorizontalLine(
        y: 100,
        color: Colors.red.withValues(alpha: 0.5),
        strokeWidth: 1,
        dashArray: [5, 5],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topRight,
          padding: const EdgeInsets.only(right: 8, top: 4),
          style: TextStyle(
            color: Colors.red.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          labelResolver: (line) => '100',
        ),
      ),
      // Повышенное давление (оранжевая линия)
      HorizontalLine(
        y: 140,
        color: Colors.orange.withValues(alpha: 0.5),
        strokeWidth: 1,
        dashArray: [5, 5],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topRight,
          padding: const EdgeInsets.only(right: 8, top: 4),
          style: TextStyle(
            color: Colors.orange.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          labelResolver: (line) => '140',
        ),
      ),
      HorizontalLine(
        y: 90,
        color: Colors.orange.withValues(alpha: 0.5),
        strokeWidth: 1,
        dashArray: [5, 5],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topRight,
          padding: const EdgeInsets.only(right: 8, top: 4),
          style: TextStyle(
            color: Colors.orange.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          labelResolver: (line) => '90',
        ),
      ),
      // Нормальное повышенное давление (желтая линия)
      HorizontalLine(
        y: 130,
        color: Colors.amber.withValues(alpha: 0.5),
        strokeWidth: 1,
        dashArray: [5, 5],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topRight,
          padding: const EdgeInsets.only(right: 8, top: 4),
          style: TextStyle(
            color: Colors.amber.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          labelResolver: (line) => '130',
        ),
      ),
      HorizontalLine(
        y: 85,
        color: Colors.amber.withValues(alpha: 0.5),
        strokeWidth: 1,
        dashArray: [5, 5],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topRight,
          padding: const EdgeInsets.only(right: 8, top: 4),
          style: TextStyle(
            color: Colors.amber.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          labelResolver: (line) => '85',
        ),
      ),
    ];
  }

  static double getMinY(List<Measurement> measurements) {
    if (measurements.isEmpty) return 0;
    final minPulse = measurements
        .map((m) => m.pulse)
        .reduce((a, b) => a < b ? a : b);
    final minDiastolic = measurements
        .map((m) => m.diastolic)
        .reduce((a, b) => a < b ? a : b);
    return (minPulse < minDiastolic ? minPulse : minDiastolic).toDouble() - 10;
  }

  static double getMaxY(List<Measurement> measurements) {
    if (measurements.isEmpty) return 200;
    final maxSystolic = measurements
        .map((m) => m.systolic)
        .reduce((a, b) => a > b ? a : b);
    return maxSystolic.toDouble() + 20;
  }
}
