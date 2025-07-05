import 'dart:io';
import 'package:xml/xml.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tonometr/database/db.dart';

class XmlExportService {
  /// Экспортирует измерения давления в XML файл
  static Future<String> exportToXml(List<Measurement> measurements) async {
    final builder = XmlBuilder();

    builder.element(
      'BLOOD_PRESSURE_DATA',
      nest: () {
        builder.attribute('export_date', DateTime.now().toIso8601String());
        builder.attribute('total_measurements', measurements.length.toString());

        for (final measurement in measurements) {
          builder.element(
            'INDICATION',
            nest: () {
              // Форматируем дату в формат YYYYMMDD
              final date = _formatDate(measurement.createdAt);
              // Форматируем время в формат HHMM
              final time = _formatTime(measurement.createdAt);

              builder.attribute('date', date);
              builder.attribute('time', time);
              builder.attribute('upper_1', measurement.systolic.toString());
              builder.attribute('lower_1', measurement.diastolic.toString());
              builder.attribute('pulse_1', measurement.pulse.toString());
              builder.attribute(
                'comments',
                measurement.note?.isNotEmpty == true ? measurement.note! : '',
              );
            },
          );
        }
      },
    );

    final document = builder.buildDocument();
    return document.toXmlString(pretty: true);
  }

  /// Сохраняет XML в файл
  static Future<File?> saveXmlToFile(String xmlContent, String fileName) async {
    try {
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        // Если папка загрузок недоступна, используем временную директорию
        final tempDirectory = Directory.systemTemp;
        final file = File('${tempDirectory.path}/$fileName');
        await file.writeAsString(xmlContent);
        return file;
      }

      final file = File('/storage/emulated/0/Download/$fileName');
      await file.writeAsString(xmlContent);
      return file;
    } catch (e) {
      return null;
    }
  }

  /// Генерирует имя файла с текущей датой
  static String generateFileName() {
    final now = DateTime.now();
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final time =
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    return 'blood_pressure_export_${date}_$time.xml';
  }

  /// Форматирует дату в формат YYYYMMDD
  static String _formatDate(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  /// Форматирует время в формат HHMM
  static String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}${date.minute.toString().padLeft(2, '0')}';
  }
}
