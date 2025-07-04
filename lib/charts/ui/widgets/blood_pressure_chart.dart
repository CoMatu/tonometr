import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tonometr/database/db.dart';
import 'package:tonometr/charts/data/chart_data_service.dart';

class BloodPressureChart extends StatelessWidget {
  final List<Measurement> measurements;
  final ChartPeriod period;

  const BloodPressureChart({
    super.key,
    required this.measurements,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) {
      return const Center(
        child: Text(
          'Нет данных для отображения',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    final systolicData = ChartDataService.prepareSystolicData(measurements);
    final diastolicData = ChartDataService.prepareDiastolicData(measurements);
    final pulseData = ChartDataService.preparePulseData(measurements);
    final xAxisLabels = ChartDataService.prepareXAxisLabels(measurements);
    final visibleLabelIndices = ChartDataService.getVisibleLabelIndices(
      measurements,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Определяем ориентацию на основе соотношения сторон
        final isLandscape = constraints.maxWidth > constraints.maxHeight;

        // Вычисляем оптимальную высоту для графика
        double chartHeight;
        if (isLandscape) {
          // В горизонтальной ориентации используем большую часть доступной высоты
          chartHeight = constraints.maxHeight * 0.9;
        } else {
          // В вертикальной ориентации используем большую часть доступной высоты
          chartHeight = constraints.maxHeight * 0.85;
        }

        return Container(
          height: chartHeight,
          padding: const EdgeInsets.all(8), // Уменьшаем отступы
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize:
                        isLandscape ? 50 : 70, // Уменьшаем отступ для подписей
                    interval:
                        1, // Используем интервал 1, но показываем только нужные подписи
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 &&
                          index < xAxisLabels.length &&
                          visibleLabelIndices.contains(index)) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 4.0,
                          ), // Уменьшаем отступ
                          child: Text(
                            xAxisLabels[index],
                            style: TextStyle(
                              fontSize:
                                  isLandscape
                                      ? 9
                                      : 8, // Уменьшаем размер шрифта
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false, reservedSize: 0),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              minX: 0,
              maxX: (measurements.length - 1).toDouble(),
              minY: ChartDataService.getMinY(measurements),
              maxY: ChartDataService.getMaxY(measurements),
              lineBarsData: [
                // Систолическое давление
                LineChartBarData(
                  spots: systolicData,
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Colors.red,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(show: false),
                ),
                // Диастолическое давление
                LineChartBarData(
                  spots: diastolicData,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Colors.blue,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(show: false),
                ),
                // Пульс
                LineChartBarData(
                  spots: pulseData,
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Colors.green,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              extraLinesData: ExtraLinesData(
                horizontalLines: ChartDataService.getHypertensionLines(),
              ),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    final measurement =
                        measurements[touchedBarSpots.first.x.toInt()];

                    return touchedBarSpots.map((barSpot) {
                      String label = '';
                      Color color = Colors.white;

                      if (barSpot.barIndex == 0) {
                        label = 'Систолическое: ${measurement.systolic}';
                        color = Colors.red;
                      } else if (barSpot.barIndex == 1) {
                        label = 'Диастолическое: ${measurement.diastolic}';
                        color = Colors.blue;
                      } else if (barSpot.barIndex == 2) {
                        label = 'Пульс: ${measurement.pulse}';
                        color = Colors.green;
                      }

                      return LineTooltipItem(
                        label,
                        TextStyle(color: color, fontWeight: FontWeight.bold),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
