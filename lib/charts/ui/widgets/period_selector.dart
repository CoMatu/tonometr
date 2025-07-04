import 'package:flutter/material.dart';
import 'package:tonometr/charts/data/chart_data_service.dart';

class PeriodSelector extends StatelessWidget {
  final ChartPeriod selectedPeriod;
  final ValueChanged<ChartPeriod> onPeriodChanged;
  final VoidCallback? onCustomPeriodPressed;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.onCustomPeriodPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SegmentedButton<ChartPeriod>(
            segments: const [
              ButtonSegment<ChartPeriod>(
                value: ChartPeriod.week,
                label: Text('Неделя'),
              ),
              ButtonSegment<ChartPeriod>(
                value: ChartPeriod.month,
                label: Text('Месяц'),
              ),
            ],
            selected: {selectedPeriod},
            onSelectionChanged: (Set<ChartPeriod> newSelection) {
              onPeriodChanged(newSelection.first);
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onCustomPeriodPressed,
          icon: const Icon(Icons.calendar_today),
          tooltip: 'Произвольный период',
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ],
    );
  }
}
