import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PeriodSelectorDialog extends StatefulWidget {
  const PeriodSelectorDialog({super.key});

  @override
  State<PeriodSelectorDialog> createState() => _PeriodSelectorDialogState();
}

class _PeriodSelectorDialogState extends State<PeriodSelectorDialog> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // По умолчанию устанавливаем период за последний месяц
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month - 1, now.day);
    _endDate = now;
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Выберите период'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Начальная дата'),
            subtitle: Text(
              _startDate != null
                  ? DateFormat('dd.MM.yyyy').format(_startDate!)
                  : 'Не выбрана',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _selectStartDate,
          ),
          ListTile(
            title: const Text('Конечная дата'),
            subtitle: Text(
              _endDate != null
                  ? DateFormat('dd.MM.yyyy').format(_endDate!)
                  : 'Не выбрана',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _selectEndDate,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed:
              (_startDate != null && _endDate != null)
                  ? () => Navigator.of(
                    context,
                  ).pop({'startDate': _startDate, 'endDate': _endDate})
                  : null,
          child: const Text('Экспорт'),
        ),
      ],
    );
  }
}
