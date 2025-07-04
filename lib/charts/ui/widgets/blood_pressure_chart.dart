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

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 80,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 &&
                        value.toInt() < xAxisLabels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          xAxisLabels[value.toInt()],
                          style: const TextStyle(
                            fontSize: 9,
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
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
      ),
    );
  }
}
