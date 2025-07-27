import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:tango/constants.dart';
import 'package:tango/services/learning_repository.dart';
import 'package:tango/services/word_repository.dart';
import 'test_harness.dart';

void main() {
  initTestHarness();

  test('harness opens each required Hive box', () {
    expect(Hive.isBoxOpen(favoritesBoxName), isTrue);
    expect(Hive.isBoxOpen(historyBoxName), isTrue);
    expect(Hive.isBoxOpen(quizStatsBoxName), isTrue);
    expect(Hive.isBoxOpen(flashcardStateBoxName), isTrue);
    expect(Hive.isBoxOpen(WordRepository.boxName), isTrue);
    expect(Hive.isBoxOpen(LearningRepository.boxName), isTrue);
    expect(Hive.isBoxOpen(sessionLogBoxName), isTrue);
    expect(Hive.isBoxOpen(reviewQueueBoxName), isTrue);
    expect(Hive.isBoxOpen(settingsBoxName), isTrue);
    expect(Hive.isBoxOpen(bookmarksBoxName), isTrue);
  });
}
