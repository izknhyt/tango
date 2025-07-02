import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HistoryBarChart extends StatelessWidget {
  final List<BarChartGroupData> bars;
  final List<String> labels;

  const HistoryBarChart({
    super.key,
    required this.bars,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    double maxVal = 0;
    for (final g in bars) {
      for (final r in g.barRods) {
        maxVal = math.max(maxVal, r.toY);
      }
    }
    double interval = 10.0;
    while (maxVal / interval > 6) {
      interval *= 2;
      if (interval == 40) interval = 60;
    }
    final maxY = math.max((maxVal / interval).ceil() * interval, interval);
    return BarChart(
      BarChartData(
        barGroups: bars,
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
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style:
                    Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
              ),
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
