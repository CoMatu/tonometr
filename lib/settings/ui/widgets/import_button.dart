import 'package:flutter/material.dart';
import 'package:tonometr/core/ui_kit/show_top_snackbar.dart';
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
          showTopSnackBar(
            context: context,
            message: 'Файл не выбран',
            type: TopSnackBarType.error,
          );
        }
        return;
      }

      if (measurements.isEmpty) {
        if (mounted) {
          showTopSnackBar(
            context: context,
            message: 'Файл не содержит данных для импорта',
            type: TopSnackBarType.error,
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
                    showTopSnackBar(
                      // ignore: use_build_context_synchronously
                      context: context,
                      message:
                          success
                              ? 'Импортировано ${measurements.length} измерений'
                              : 'Ошибка при импорте',
                      type:
                          success
                              ? TopSnackBarType.success
                              : TopSnackBarType.error,
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
