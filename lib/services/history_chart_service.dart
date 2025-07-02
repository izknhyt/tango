import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';

import '../history_entry_model.dart';
import '../models/quiz_stat.dart';
import '../constants.dart';
import '../learning_history_detail_screen.dart';

class HistoryChartService {
  final Box<HistoryEntry> _historyBox;
  final Box<QuizStat> _quizStatsBox;

  HistoryChartService([
    Box<HistoryEntry>? historyBox,
    Box<QuizStat>? quizStatsBox,
  ])  : _historyBox = historyBox ?? Hive.box<HistoryEntry>(historyBoxName),
        _quizStatsBox = quizStatsBox ?? Hive.box<QuizStat>(quizStatsBoxName);

  DateTime _addMonths(DateTime date, int months) {
    return DateTime(date.year, date.month + months, 1);
  }

  List<DateTimeRange> currentRanges(ViewMode mode, int offset) {
    final now = DateTime.now();
    switch (mode) {
      case ViewMode.day:
        final end = DateTime(now.year, now.month, now.day)
            .add(Duration(days: offset * 7));
        final start = end.subtract(const Duration(days: 6));
        return List.generate(7, (i) {
          final s = start.add(Duration(days: i));
          return DateTimeRange(start: s, end: s.add(const Duration(days: 1)));
        });
      case ViewMode.week:
        const points = 6;
        final weekStart =
            DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
        final end = weekStart.add(Duration(days: 7 * offset));
        final start = end.subtract(Duration(days: 7 * (points - 1)));
        return List.generate(points, (i) {
          final s = start.add(Duration(days: 7 * i));
          return DateTimeRange(start: s, end: s.add(const Duration(days: 7)));
        });
      case ViewMode.month:
        const points = 6;
        final monthStart = DateTime(now.year, now.month, 1);
        final end = _addMonths(monthStart, offset);
        final start = _addMonths(end, -(points - 1));
        return List.generate(points, (i) {
          final s = _addMonths(start, i);
          return DateTimeRange(start: s, end: _addMonths(s, 1));
        });
    }
  }

  List<FlSpot> learnedSpots(List<DateTimeRange> ranges) {
    return List.generate(ranges.length, (i) {
      final r = ranges[i];
      final count = _historyBox.values
          .where((e) => e.timestamp.isAfter(r.start) && e.timestamp.isBefore(r.end))
          .map((e) => e.wordId)
          .toSet()
          .length;
      return FlSpot(i.toDouble(), count.toDouble());
    });
  }

  List<FlSpot> accuracySpots(List<DateTimeRange> ranges) {
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

  List<BarChartGroupData> timeBars(List<DateTimeRange> ranges) {
    return List.generate(ranges.length, (i) {
      final r = ranges[i];
      int secs = 0;
      for (var m in _quizStatsBox.values) {
        final ts = m.timestamp;
        if (ts.isAfter(r.start) && ts.isBefore(r.end)) {
          secs += m.durationSeconds;
        }
      }
      return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: secs.toDouble() / 60.0)]);
    });
  }
}
