import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tonometr/settings/domain/export_controller.dart';
import 'package:tonometr/core/initialization/ui/inherited_dependencies.dart';
import 'package:tonometr/settings/ui/dialogs/export_options_dialog.dart';
import 'package:tonometr/settings/ui/dialogs/period_selector_dialog.dart';

class ExportButton extends StatefulWidget {
  final VoidCallback? onExportComplete;

  const ExportButton({super.key, this.onExportComplete});

  @override
  State<ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<ExportButton> {
  ExportController? _exportController;
  bool _isExporting = false;

  void _initializeController() {
    final dependencies = InheritedDependencies.of(context);
    _exportController = ExportController(dependencies.database);
  }

  Future<void> _showExportOptions() async {
    if (_exportController == null) {
      _initializeController();
    }

    if (mounted) {
      final result = await showDialog<ExportOption>(
        context: context,
        builder: (context) => const ExportOptionsDialog(),
      );

      if (result != null) {
        await _performExport(result);
      }
    }
  }

  Future<void> _performExport(ExportOption option) async {
    setState(() {
      _isExporting = true;
    });

    try {
      File? exportedFile;

      switch (option) {
        case ExportOption.allData:
          exportedFile = await _exportController!.exportAllMeasurements();
          break;
        case ExportOption.customPeriod:
          final periodResult = await showDialog<Map<String, DateTime>>(
            context: context,
            builder: (context) => const PeriodSelectorDialog(),
          );

          if (periodResult != null) {
            final startDate = periodResult['startDate']!;
            final endDate = periodResult['endDate']!;
            exportedFile = await _exportController!.exportMeasurementsByPeriod(
              startDate,
              endDate,
            );
          }
          break;
      }

      if (exportedFile != null) {
        if (mounted) {
          final fileName = exportedFile.path.split('/').last;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Данные экспортированы в файл: $fileName'),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Открыть',
                onPressed: () {
                  // Здесь можно добавить логику для открытия файла
                },
              ),
            ),
          );
          widget.onExportComplete?.call();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Нет данных для экспорта')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка при экспорте: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed: _isExporting ? null : _showExportOptions,
        icon:
            _isExporting
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.file_download),
        label: Text(_isExporting ? 'Экспорт...' : 'Экспорт в XML'),
      ),
    );
  }
}

enum ExportOption { allData, customPeriod }
