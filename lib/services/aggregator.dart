import 'package:hive/hive.dart';

import '../models/session_log.dart';
import '../constants.dart';

class SessionAggregator {
  final Box<SessionLog> _box;
  final DateTime Function() _now;

  SessionAggregator([
    Box<SessionLog>? box,
    DateTime Function()? now,
  ])  : _box = box ?? Hive.box<SessionLog>(sessionLogBoxName),
        _now = now ?? DateTime.now;

  Future<Map<DateTime, Duration>> dailyStudyTime({
    DateTime? from,
    DateTime? to,
  }) async {
    final logs = _box.values.toList();
    if (logs.isEmpty) return {};
    final start = from ??
        logs.map((e) => e.startTime).reduce((a, b) => a.isBefore(b) ? a : b);
    final end = to ?? _now();
    final Map<DateTime, Duration> result = {};
    for (final log in logs) {
      if (log.startTime.isBefore(start) || log.startTime.isAfter(end)) continue;
      final date = DateTime(log.startTime.year, log.startTime.month, log.startTime.day);
      final dur = log.endTime.difference(log.startTime);
      result[date] = (result[date] ?? Duration.zero) + dur;
    }
    return result;
  }

  int currentStreak() {
    final dates = _box.values.map((e) {
      return DateTime(e.startTime.year, e.startTime.month, e.startTime.day);
    }).toSet();
    int streak = 0;
    DateTime day = _now();
    while (true) {
      final d = DateTime(day.year, day.month, day.day);
      if (dates.contains(d)) {
        streak += 1;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
