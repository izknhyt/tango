import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import 'package:tango/history_entry_model.dart';

const String historyBoxName = 'history_box_v2';
const String quizStatsBoxName = 'quiz_stats_box_v1';

class LearningHistoryDetailScreen extends StatefulWidget {
  const LearningHistoryDetailScreen({Key? key}) : super(key: key);

  @override
  State<LearningHistoryDetailScreen> createState() =>
      _LearningHistoryDetailScreenState();
}

class _LearningHistoryDetailScreenState
    extends State<LearningHistoryDetailScreen> {
  late Box<HistoryEntry> _historyBox;
  late Box<Map> _quizStatsBox;

  @override
  void initState() {
    super.initState();
    _historyBox = Hive.box<HistoryEntry>(historyBoxName);
    _quizStatsBox = Hive.box<Map>(quizStatsBoxName);
  }

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

  List<FlSpot> _learnedSpots() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));
      final count = _historyBox.values
          .cast<HistoryEntry>()
          .where((e) => e.timestamp.isAfter(start) && e.timestamp.isBefore(end))
          .map((e) => e.wordId)
          .toSet()
          .length;
      return FlSpot(i.toDouble(), count.toDouble());
    });
  }

  List<FlSpot> _accuracySpots() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));
      int q = 0;
      int c = 0;
      for (var m in _quizStatsBox.values.cast<Map>()) {
        final ts = m['timestamp'] as DateTime?;
        if (ts != null && ts.isAfter(start) && ts.isBefore(end)) {
          q += m['questionCount'] as int? ?? 0;
          c += m['correctCount'] as int? ?? 0;
        }
      }
      final acc = q == 0 ? 0.0 : c / q * 100;
      return FlSpot(i.toDouble(), acc);
    });
  }

  List<BarChartGroupData> _timeBars() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));
      int secs = 0;
      for (var m in _quizStatsBox.values.cast<Map>()) {
        final ts = m['timestamp'] as DateTime?;
        if (ts != null && ts.isAfter(start) && ts.isBefore(end)) {
          secs += m['durationSeconds'] as int? ?? 0;
        }
      }
      return BarChartGroupData(
          x: i, barRods: [BarChartRodData(toY: secs.toDouble() / 60.0)]);
    });
  }

  Widget _buildLineChart(List<FlSpot> spots, {bool isPercent = false}) {
    final now = DateTime.now();
    final maxVal = spots.fold<double>(0, (p, e) => math.max(p, e.y));
    final range = isPercent ? 100.0 : maxVal;
    final interval = _niceInterval(range);
    final maxY = isPercent ? 100.0 : (range / interval).ceil() * interval;
    return LineChart(
      LineChartData(
        lineBarsData: [LineChartBarData(spots: spots, isCurved: true)],
        minY: 0,
        maxY: maxY,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx > 6) {
                  return const SizedBox.shrink();
                }
                final day = now.subtract(Duration(days: 6 - idx));
                final label = DateFormat('M/d').format(day);
                return Text(label, style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString(),
                    style: const TextStyle(fontSize: 10));
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

  Widget _buildBarChart(List<BarChartGroupData> bars) {
    final now = DateTime.now();
    double maxVal = 0;
    for (final g in bars) {
      for (final r in g.barRods) {
        maxVal = math.max(maxVal, r.toY);
      }
    }
    final interval = _niceInterval(maxVal);
    final maxY = (maxVal / interval).ceil() * interval;
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
                if (idx < 0 || idx > 6) {
                  return const SizedBox.shrink();
                }
                final day = now.subtract(Duration(days: 6 - idx));
                final label = DateFormat('M/d').format(day);
                return Text(label, style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              reservedSize: 32,
              getTitlesWidget: (value, meta) =>
                  Text(value.toInt().toString(),
                      style: const TextStyle(fontSize: 10)),
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _historyBox.listenable(),
      builder: (context, _, __) {
        return ValueListenableBuilder(
          valueListenable: _quizStatsBox.listenable(),
          builder: (context, __, ___) {
            return ListView(
              padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('学習単語数の推移'),
                          SizedBox(
                              height: 200,
                              child: _buildLineChart(_learnedSpots())),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('正解率の推移'),
                          SizedBox(
                              height: 200,
                              child: _buildLineChart(_accuracySpots(),
                                  isPercent: true)),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('学習時間の推移 (分)'),
                          SizedBox(
                              height: 200,
                              child: _buildBarChart(_timeBars())),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
 }
}
