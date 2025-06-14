import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

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

  Widget _buildLineChart(List<FlSpot> spots) {
    return LineChart(
      LineChartData(
        lineBarsData: [LineChartBarData(spots: spots, isCurved: true)],
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        minY: 0,
      ),
    );
  }

  Widget _buildBarChart(List<BarChartGroupData> bars) {
    return BarChart(
      BarChartData(
        barGroups: bars,
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('学習履歴詳細')),
      body: ValueListenableBuilder(
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
                              child: _buildLineChart(_accuracySpots())),
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
                              height: 200, child: _buildBarChart(_timeBars())),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
