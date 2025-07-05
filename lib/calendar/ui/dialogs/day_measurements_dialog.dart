import 'package:flutter/material.dart';
import 'package:tonometr/database/db.dart';
import 'package:tonometr/core/utils/color_utils.dart';
import 'package:intl/intl.dart';

class DayMeasurementsDialog extends StatelessWidget {
  final DateTime selectedDay;
  final List<Measurement> measurements;

  const DayMeasurementsDialog({
    super.key,
    required this.selectedDay,
    required this.measurements,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateString = DateFormat('dd.MM.yyyy').format(selectedDay);

    // Сортируем измерения по времени (самые ранние сверху)
    final sortedMeasurements = List<Measurement>.from(measurements)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: theme.colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Измерения за $dateString',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: theme.colorScheme.onPrimary),
                  ),
                ],
              ),
            ),
            Flexible(
              child:
                  sortedMeasurements.isEmpty
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Нет измерений за этот день',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: sortedMeasurements.length,
                        itemBuilder: (context, index) {
                          final measurement = sortedMeasurements[index];
                          final timeString = DateFormat(
                            'HH:mm',
                          ).format(measurement.createdAt);

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: getCategoryColor(
                                  measurement.systolic,
                                  measurement.diastolic,
                                ),
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                '${measurement.systolic}/${measurement.diastolic} мм рт.ст.',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Пульс: ${measurement.pulse} уд/мин • $timeString',
                                style: TextStyle(
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                              trailing:
                                  measurement.note?.isNotEmpty == true
                                      ? Icon(
                                        Icons.note,
                                        color: theme.colorScheme.primary,
                                      )
                                      : null,
                            ),
                          );
                        },
                      ),
            ),
            if (sortedMeasurements.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Всего измерений: ${sortedMeasurements.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
