import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:tango/models/session_log.dart';
import 'package:tango/services/aggregator.dart';
import 'package:tango/constants.dart';

void main() {
  late Directory dir;
  late Box<SessionLog> box;
  late SessionAggregator aggregator;
  late DateTime fixedNow;

  SessionLog _log(DateTime start, int minutes) => SessionLog(
        startTime: start,
        endTime: start.add(Duration(minutes: minutes)),
        wordCount: 0,
        correctCount: 0,
      );

  setUp(() async {
    fixedNow = DateTime(2025, 1, 15, 12);
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    Hive.registerAdapter(SessionLogAdapter());
    box = await Hive.openBox<SessionLog>(sessionLogBoxName);
    aggregator = SessionAggregator(box, () => fixedNow);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk(sessionLogBoxName);
    await dir.delete(recursive: true);
  });

  test('aggregates and streak', () async {
    final today = DateTime(fixedNow.year, fixedNow.month, fixedNow.day);
    await box.add(_log(today.add(const Duration(hours: 1)), 30));
    await box.add(
        _log(today.subtract(const Duration(days: 1)).add(const Duration(hours: 1)), 20));
    await box.add(
        _log(today.subtract(const Duration(days: 3)).add(const Duration(hours: 1)), 10));

    final daily = await aggregator.dailyStudyTime();
    expect(daily[today]?.inMinutes, 30);
    expect(daily.length, 3);
    expect(aggregator.currentStreak(), 2);
  });
}
