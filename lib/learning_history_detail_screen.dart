import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import 'package:tango/history_entry_model.dart';
import 'constants.dart';
import 'models/quiz_stat.dart';

enum ViewMode { day, week, month }

class LearningHistoryDetailScreen extends StatefulWidget {
  const LearningHistoryDetailScreen({Key? key}) : super(key: key);

  @override
  State<LearningHistoryDetailScreen> createState() =>
      _LearningHistoryDetailScreenState();
}

class _LearningHistoryDetailScreenState
    extends State<LearningHistoryDetailScreen> {
  late Box<HistoryEntry> _historyBox;
  late Box<QuizStat> _quizStatsBox;
  ViewMode _mode = ViewMode.day;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _historyBox = Hive.box<HistoryEntry>(historyBoxName);
    _quizStatsBox = Hive.box<QuizStat>(quizStatsBoxName);
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

  DateTime _addMonths(DateTime date, int months) {
    return DateTime(date.year, date.month + months, 1);
  }

  List<DateTimeRange> _currentRanges() {
    final now = DateTime.now();
    switch (_mode) {
      case ViewMode.day:
        final end = DateTime(now.year, now.month, now.day)
            .add(Duration(days: _offset * 7));
        final start = end.subtract(const Duration(days: 6));
        return List.generate(7, (i) {
          final s = start.add(Duration(days: i));
          return DateTimeRange(start: s, end: s.add(const Duration(days: 1)));
        });
      case ViewMode.week:
        const points = 6;
        final weekStart = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        final end = weekStart.add(Duration(days: 7 * _offset));
        final start = end.subtract(Duration(days: 7 * (points - 1)));
        return List.generate(points, (i) {
          final s = start.add(Duration(days: 7 * i));
          return DateTimeRange(start: s, end: s.add(const Duration(days: 7)));
        });
      case ViewMode.month:
        const points = 6;
        final monthStart = DateTime(now.year, now.month, 1);
        final end = _addMonths(monthStart, _offset);
        final start = _addMonths(end, -(points - 1));
        return List.generate(points, (i) {
          final s = _addMonths(start, i);
          return DateTimeRange(start: s, end: _addMonths(s, 1));
        });
    }
  }

  List<FlSpot> _learnedSpots(List<DateTimeRange> ranges) {
    return List.generate(ranges.length, (i) {
      final r = ranges[i];
      final count = _historyBox.values
          .cast<HistoryEntry>()
          .where((e) =>
              e.timestamp.isAfter(r.start) && e.timestamp.isBefore(r.end))
          .map((e) => e.wordId)
          .toSet()
          .length;
      return FlSpot(i.toDouble(), count.toDouble());
    });
  }

  List<FlSpot> _accuracySpots(List<DateTimeRange> ranges) {
    return List.generate(ranges.length, (i) {
      final r = ranges[i];
      int q = 0;
      int c = 0;
      for (var m in _quizStatsBox.values) {
        final ts = m.timestamp;
        if (ts.isAfter(r.start) && ts.isBefore(r.end)) {
          q += m.questionCount;
          c += m.correctCount;
        }
      }
      final acc = q == 0 ? 0.0 : c / q * 100;
      return FlSpot(i.toDouble(), acc);
    });
  }

  List<BarChartGroupData> _timeBars(List<DateTimeRange> ranges) {
    return List.generate(ranges.length, (i) {
      final r = ranges[i];
      int secs = 0;
      for (var m in _quizStatsBox.values) {
        final ts = m.timestamp;
        if (ts.isAfter(r.start) && ts.isBefore(r.end)) {
          secs += m.durationSeconds;
        }
      }
      return BarChartGroupData(
          x: i, barRods: [BarChartRodData(toY: secs.toDouble() / 60.0)]);
    });
  }

  Widget _buildLineChart(List<FlSpot> spots, List<String> labels,
      {bool isPercent = false}) {
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
                return Text(labels[idx],
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(fontSize: 10));
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
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(fontSize: 10));
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

  Widget _buildBarChart(List<BarChartGroupData> bars, List<String> labels) {
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
                return Text(labels[idx],
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(fontSize: 10));
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
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(fontSize: 10),
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _historyBox.listenable(),
      builder: (context, _, __) {
        return ValueListenableBuilder(
          valueListenable: _quizStatsBox.listenable(),
          builder: (context, __, ___) {
            final ranges = _currentRanges();
            final dateFormat = _mode == ViewMode.month
                ? DateFormat('yyyy/MM')
                : DateFormat('M/d');
            final labels =
                ranges.map((r) => dateFormat.format(r.start)).toList();

            final learned = _learnedSpots(ranges);
            final accuracy = _accuracySpots(ranges);
            final timeBars = _timeBars(ranges);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ToggleButtons(
                  isSelected: ViewMode.values.map((m) => m == _mode).toList(),
                  onPressed: (index) {
                    setState(() {
                      _mode = ViewMode.values[index];
                      _offset = 0;
                    });
                  },
                  children: const [Text('日'), Text('週'), Text('月')],
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('学習単語数の推移'),
                        SizedBox(
                          height: 200,
                          child: GestureDetector(
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity == null) return;
                              setState(() {
                                if (details.primaryVelocity! < 0) {
                                  _offset--;
                                } else if (details.primaryVelocity! > 0) {
                                  _offset++;
                                }
                              });
                            },
                            child: _buildLineChart(learned, labels),
                          ),
                        ),
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
                          child: GestureDetector(
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity == null) return;
                              setState(() {
                                if (details.primaryVelocity! < 0) {
                                  _offset--;
                                } else if (details.primaryVelocity! > 0) {
                                  _offset++;
                                }
                              });
                            },
                            child: _buildLineChart(accuracy, labels,
                                isPercent: true),
                          ),
                        ),
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
                          child: GestureDetector(
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity == null) return;
                              setState(() {
                                if (details.primaryVelocity! < 0) {
                                  _offset--;
                                } else if (details.primaryVelocity! > 0) {
                                  _offset++;
                                }
                              });
                            },
                            child: _buildBarChart(timeBars, labels),
                          ),
                        ),
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
  }
}
