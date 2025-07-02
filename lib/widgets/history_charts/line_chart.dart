import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HistoryLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final List<String> labels;
  final bool isPercent;

  const HistoryLineChart({
    super.key,
    required this.spots,
    required this.labels,
    this.isPercent = false,
  });

  double _niceInterval(double maxValue) {
    if (maxValue <= 0) return 1;
    final rawStep = maxValue / 5;
    final exponent = (math.log(rawStep) / math.ln10).floor();
    final magnitude = math.pow(10, exponent).toDouble();
    final residual = rawStep / magnitude;
    double step;
    if (residual > 5) {
      step = 10;
    } else if (residual > 2) {
      step = 5;
    } else if (residual > 1) {
      step = 2;
    } else {
      step = 1;
    }
    return (step * magnitude).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final maxVal = spots.fold<double>(0, (p, e) => math.max(p, e.y));
    final range = isPercent ? 100.0 : maxVal;
    final interval = _niceInterval(range);
    final maxY = isPercent ? 100.0 : (range / interval).ceil() * interval;
    return LineChart(
      LineChartData(
        lineBarsData: [LineChartBarData(spots: spots, isCurved: false)],
        minY: 0,
        maxY: maxY,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  labels[idx],
                  style:
                      Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style:
                      Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: true),
      ),
    );
  }
}
