import 'package:flutter/material.dart';
import 'package:tonometr/core/utils/color_utils.dart';
import 'package:tonometr/database/db.dart';

class CalendarDayCell extends StatelessWidget {
  final DateTime day;
  final List<Measurement> measurements;
  final bool isSelected;
  final bool isToday;
  final Color? backgroundColor;
  final Color? textColor;

  const CalendarDayCell({
    super.key,
    required this.day,
    required this.measurements,
    this.isSelected = false,
    this.isToday = false,
    this.backgroundColor,
    this.textColor,
  });

  String _getAveragePressure() {
    if (measurements.isEmpty) return '';

    final avgSystolic =
        measurements.map((m) => m.systolic).reduce((a, b) => a + b) ~/
        measurements.length;

    final avgDiastolic =
        measurements.map((m) => m.diastolic).reduce((a, b) => a + b) ~/
        measurements.length;

    return '$avgSystolic\n$avgDiastolic';
  }

  Color _getBorderColor() {
    if (measurements.isEmpty) return Colors.transparent;

    final maxSystolic = measurements
        .map((m) => m.systolic)
        .reduce((a, b) => a > b ? a : b);
    final maxDiastolic = measurements
        .map((m) => m.diastolic)
        .reduce((a, b) => a > b ? a : b);

    return getCategoryColor(maxSystolic, maxDiastolic);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final hasEvents = measurements.isNotEmpty;
    final effectiveBackgroundColor =
        backgroundColor ??
        (isSelected
            ? Colors.grey.withValues(alpha: isDarkMode ? 0.3 : 0.2)
            : isToday
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
            : Colors.transparent);

    final effectiveTextColor =
        textColor ??
        (isSelected
            ? Colors.black
            : hasEvents
            ? isDarkMode
                ? Colors.grey
                : Colors.black
            : isDarkMode
            ? Colors.white
            : Colors.grey);

    return Container(
      margin: const EdgeInsets.all(2),
      constraints: const BoxConstraints(minHeight: 60),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        border: Border.all(
          color: hasEvents ? _getBorderColor() : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: effectiveTextColor,
                fontStyle: FontStyle.italic,
                decoration: TextDecoration.underline,
                fontWeight:
                    (hasEvents || isSelected || isToday)
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
            ),
            if (hasEvents) ...[
              const SizedBox(height: 2),
              Text(
                _getAveragePressure(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: effectiveTextColor,
                  height: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
