import 'package:flutter/material.dart';
import 'package:tonometr/core/services/xml_import_service.dart';
import 'package:tonometr/core/utils/datetime_utils.dart' as date_utils;

class ImportPreviewDialog extends StatelessWidget {
  final List<MeasurementPreview> measurements;
  final VoidCallback onConfirm;

  const ImportPreviewDialog({
    super.key,
    required this.measurements,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Предварительный просмотр'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            Text(
              'Найдено ${measurements.length} измерений',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: measurements.length,
                itemBuilder: (context, index) {
                  final measurement = measurements[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        '${measurement.systolic}/${measurement.diastolic} мм рт.ст.',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Пульс: ${measurement.pulse} уд/мин'),
                          Text(
                            'Дата: ${date_utils.formatDate(measurement.createdAt)}',
                          ),
                          if (measurement.note != null)
                            Text(
                              'Заметка: ${measurement.note}',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text('Импортировать'),
        ),
      ],
    );
  }
}
