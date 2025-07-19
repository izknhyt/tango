import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:tango/models/word.dart';
import 'package:tango/models/learning_stat.dart';
import 'package:tango/services/word_repository.dart';
import 'package:tango/services/learning_repository.dart';
import 'package:tango/services/flashcard_loader.dart';
import 'test_harness.dart';

void main() {
  late Directory hiveTempDir;
  late WordRepository wordRepo;
  late LearningRepository learningRepo;
  late HiveFlashcardLoader loader;

  setUpAll(() async {
    hiveTempDir = await initHiveForTests();
    await openAllBoxes();
    wordRepo = await WordRepository.open();
    learningRepo = await LearningRepository.open();
    loader = HiveFlashcardLoader(wordRepo: wordRepo, learningRepo: learningRepo);
  });

  tearDownAll(() async {
    await closeHiveForTests(hiveTempDir);
  });

  test('loads flashcards with stats merged', () async {
    await wordRepo.add(Word(
      id: '1',
      term: 'a',
      reading: 'a',
      description: 'd',
      categoryLarge: 'A',
      categoryMedium: 'B',
      categorySmall: 'C',
      categoryItem: 'D',
      importance: 1,
    ));
    await learningRepo.incrementWrong('1');

    final cards = await loader.loadAll();
    expect(cards.length, 1);
    expect(cards.first.wrongCount, 1);
  });
}
