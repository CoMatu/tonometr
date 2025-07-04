import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tonometr/core/services/xml_import_service.dart';
import 'package:tonometr/database/db.dart';

class ImportController {
  final AppDatabase database;

  ImportController(this.database);

  Future<List<MeasurementPreview>?> selectAndParseFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xml'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = File(result.files.first.path!);
      if (!await file.exists()) {
        return null;
      }

      return XmlImportService.parseXmlFile(file.path);
    } catch (e) {
      debugPrint('Ошибка при выборе или парсинге файла: $e');
      return null;
    }
  }

  Future<bool> importMeasurements(List<MeasurementPreview> measurements) async {
    try {
      for (final measurement in measurements) {
        await database.addMeasurement(measurement.toCompanion());
      }
      return true;
    } catch (e) {
      debugPrint('Ошибка при импорте: $e');
      return false;
    }
  }
}
