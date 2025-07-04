import 'package:flutter/material.dart';
import 'package:tonometr/blood_pressure/ui/indicators/blood_press_indicator.dart';
import 'package:tonometr/database/db.dart';
import 'package:tonometr/core/utils/datetime_utils.dart';

class BloodPressureCard extends StatelessWidget {
  final Measurement measurement;
  final VoidCallback onDelete;

  const BloodPressureCard({
    super.key,
    required this.measurement,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: BloodPressureCategoryIndicator(
          systolic: measurement.systolic,
          diastolic: measurement.diastolic,
        ),
        title: Text(
          '${measurement.systolic}/${measurement.diastolic} мм рт.ст.',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Пульс: ${measurement.pulse} уд/мин'),
            if (measurement.note != null && measurement.note!.isNotEmpty)
              Text('Заметка: ${measurement.note}'),
            Text(
              formatDate(measurement.createdAt),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
