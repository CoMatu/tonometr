import 'dart:io';
import 'package:tonometr/database/db.dart';
import 'package:tonometr/core/services/xml_export_service.dart';

class ExportController {
  final AppDatabase _database;

  ExportController(this._database);

  /// Получает все измерения из базы данных
  Future<List<Measurement>> getAllMeasurements() async {
    return await _database.getAllMeasurements();
  }

  /// Экспортирует все измерения в XML файл
  Future<File?> exportAllMeasurements() async {
    try {
      final measurements = await getAllMeasurements();

      if (measurements.isEmpty) {
        return null;
      }

      final xmlContent = await XmlExportService.exportToXml(measurements);
      final fileName = XmlExportService.generateFileName();

      return await XmlExportService.saveXmlToFile(xmlContent, fileName);
    } catch (e) {
      return null;
    }
  }

  /// Экспортирует измерения за определенный период
  Future<File?> exportMeasurementsByPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allMeasurements = await getAllMeasurements();

      final filteredMeasurements =
          allMeasurements.where((measurement) {
            return measurement.createdAt.isAfter(
                  startDate.subtract(const Duration(days: 1)),
                ) &&
                measurement.createdAt.isBefore(
                  endDate.add(const Duration(days: 1)),
                );
          }).toList();

      if (filteredMeasurements.isEmpty) {
        return null;
      }

      final xmlContent = await XmlExportService.exportToXml(
        filteredMeasurements,
      );
      final fileName = XmlExportService.generateFileName();

      return await XmlExportService.saveXmlToFile(xmlContent, fileName);
    } catch (e) {
      return null;
    }
  }
}
