import 'package:flutter/material.dart';
import 'package:tonometr/settings/ui/widgets/export_button.dart';

class ExportOptionsDialog extends StatelessWidget {
  const ExportOptionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Выберите опцию экспорта'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.data_usage),
            title: const Text('Все данные'),
            subtitle: const Text('Экспортировать все измерения давления'),
            onTap: () => Navigator.of(context).pop(ExportOption.allData),
          ),
          ListTile(
            leading: const Icon(Icons.date_range),
            title: const Text('За период'),
            subtitle: const Text('Выбрать период для экспорта'),
            onTap: () => Navigator.of(context).pop(ExportOption.customPeriod),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
      ],
    );
  }
}
