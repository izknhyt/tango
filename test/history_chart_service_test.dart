import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:tango/history_entry_model.dart';
import 'package:tango/models/quiz_stat.dart';
import 'package:tango/services/history_chart_service.dart';
import 'package:tango/constants.dart';
import 'package:tango/learning_history_detail_screen.dart';
import 'package:tango/hive_utils.dart' hide openTypedBox;
import 'test_harness.dart';

void main() {
  initTestHarness();
  late Box<HistoryEntry> historyBox;
  late Box<QuizStat> quizBox;
  late HistoryChartService service;

  setUp(() {
    historyBox = Hive.box<HistoryEntry>(historyBoxName);
    quizBox = Hive.box<QuizStat>(quizStatsBoxName);
    service = HistoryChartService(historyBox, quizBox);
  });

  tearDown(() async {
    await historyBox.clear();
    await quizBox.clear();
  });

  test('calculates chart data', () async {
    final now = DateTime.now();
    await historyBox.put('a', HistoryEntry(wordId: 'a', timestamp: now));
    await historyBox.put('b', HistoryEntry(wordId: 'b', timestamp: now));
    await historyBox.put('a2', HistoryEntry(wordId: 'a', timestamp: now));

    await quizBox.add(QuizStat(
      timestamp: now,
      questionCount: 5,
      correctCount: 4,
      durationSeconds: 120,
      wordIds: const [],
      results: const [],
    ));

    final ranges = [
      DateTimeRange(start: now.subtract(const Duration(days: 1)), end: now.add(const Duration(days: 1))),
    ];

    final learned = service.learnedSpots(ranges);
    expect(learned.first.y, 2);

    final acc = service.accuracySpots(ranges);
    expect(acc.first.y, closeTo(80.0, 0.01));

    final bars = service.timeBars(ranges);
    expect(bars.first.barRods.first.toY, closeTo(2.0, 0.01));
  });

  test('provides range lengths', () {
    expect(service.currentRanges(ViewMode.day, 0).length, 7);
    expect(service.currentRanges(ViewMode.week, 0).length, 6);
    expect(service.currentRanges(ViewMode.month, 0).length, 6);
  });
}
