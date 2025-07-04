import 'package:flutter/material.dart';
import 'package:tonometr/settings/domain/import_controller.dart';
import 'package:tonometr/settings/ui/dialogs/import_preview_dialog.dart';
import 'package:tonometr/core/initialization/ui/inherited_dependencies.dart';
import 'package:tonometr/core/services/event_bus.dart';

class ImportButton extends StatefulWidget {
  final VoidCallback? onImportComplete;

  const ImportButton({super.key, this.onImportComplete});

  @override
  State<ImportButton> createState() => _ImportButtonState();
}

class _ImportButtonState extends State<ImportButton> {
  ImportController? _importController;
  bool _isImporting = false;

  void _initializeController() {
    final dependencies = InheritedDependencies.of(context);
    _importController = ImportController(dependencies.database);
  }

  Future<void> _importXmlData() async {
    if (_importController == null) {
      _initializeController();
    }

    setState(() {
      _isImporting = true;
    });

    try {
      final measurements = await _importController!.selectAndParseFile();

      if (measurements == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Файл не выбран')));
        }
        return;
      }

      if (measurements.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Файл не содержит данных для импорта'),
            ),
          );
        }
        return;
      }

      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => ImportPreviewDialog(
                measurements: measurements,
                onConfirm: () async {
                  final success = await _importController!.importMeasurements(
                    measurements,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Импортировано ${measurements.length} измерений'
                              : 'Ошибка при импорте',
                        ),
                      ),
                    );

                    if (success) {
                      widget.onImportComplete?.call();
                      EventBus().emit(DataChangedEvent('measurements'));
                    }
                  }
                },
              ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed: _isImporting ? null : _importXmlData,
        icon:
            _isImporting
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.file_upload),
        label: Text(_isImporting ? 'Импорт...' : 'Импорт из XML'),
      ),
    );
  }
}
