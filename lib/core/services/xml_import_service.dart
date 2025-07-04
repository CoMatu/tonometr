import 'dart:io';
import 'package:xml/xml.dart';
import 'package:drift/drift.dart';
import 'package:tonometr/database/db.dart';

class XmlImportService {
  static List<MeasurementPreview> parseXmlFile(String filePath) {
    final file = File(filePath);
    final xmlString = file.readAsStringSync();
    final document = XmlDocument.parse(xmlString);

    final indications = document.findAllElements('INDICATION');
    final measurements = <MeasurementPreview>[];

    for (final indication in indications) {
      try {
        final date = indication.getAttribute('date') ?? '';
        final time = indication.getAttribute('time') ?? '';
        final systolic =
            int.tryParse(indication.getAttribute('upper_1') ?? '0') ?? 0;
        final diastolic =
            int.tryParse(indication.getAttribute('lower_1') ?? '0') ?? 0;
        final pulse =
            int.tryParse(indication.getAttribute('pulse_1') ?? '0') ?? 0;
        final comments = indication.getAttribute('comments') ?? '';

        if (systolic > 0 && diastolic > 0) {
          final dateTime = _parseDateTime(date, time);
          if (dateTime != null) {
            measurements.add(
              MeasurementPreview(
                systolic: systolic,
                diastolic: diastolic,
                pulse: pulse,
                note: comments.isNotEmpty ? comments : null,
                createdAt: dateTime,
              ),
            );
          }
        }
      } catch (e) {
        // Пропускаем некорректные записи
        continue;
      }
    }

    return measurements;
  }

  static DateTime? _parseDateTime(String date, String time) {
    try {
      if (date.length != 8 || time.length != 4) return null;

      final year = int.parse(date.substring(0, 4));
      final month = int.parse(date.substring(4, 6));
      final day = int.parse(date.substring(6, 8));
      final hour = int.parse(time.substring(0, 2));
      final minute = int.parse(time.substring(2, 4));

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      return null;
    }
  }
}

class MeasurementPreview {
  final int systolic;
  final int diastolic;
  final int pulse;
  final String? note;
  final DateTime createdAt;

  const MeasurementPreview({
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    this.note,
    required this.createdAt,
  });

  MeasurementsCompanion toCompanion() {
    return MeasurementsCompanion.insert(
      systolic: systolic,
      diastolic: diastolic,
      pulse: pulse,
      note: note != null ? Value(note!) : const Value.absent(),
      createdAt: Value(createdAt),
    );
  }
}
