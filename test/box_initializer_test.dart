import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:tango/constants.dart';
import 'test_harness.dart';

void main() {
  initTestHarness();

  test('harness opens each required Hive box', () {
    expect(Hive.isBoxOpen(favoritesBoxName), isTrue);
    expect(Hive.isBoxOpen(historyBoxName), isTrue);
    expect(Hive.isBoxOpen(quizStatsBoxName), isTrue);
    expect(Hive.isBoxOpen(flashcardStateBoxName), isTrue);
    expect(Hive.isBoxOpen(wordsBoxName), isTrue);
    expect(Hive.isBoxOpen(learningStatBoxName), isTrue);
    expect(Hive.isBoxOpen(sessionLogBoxName), isTrue);
    expect(Hive.isBoxOpen(reviewQueueBoxName), isTrue);
    expect(Hive.isBoxOpen(settingsBoxName), isTrue);
    expect(Hive.isBoxOpen(bookmarksBoxName), isTrue);
  });
}
