import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:tango/models/word.dart';
import 'package:tango/models/learning_stat.dart';
import 'package:tango/services/word_repository.dart';
import 'package:tango/services/learning_repository.dart';
import 'package:tango/services/flashcard_loader.dart';

void main() {
  late Directory dir;
  late WordRepository wordRepo;
  late LearningRepository learningRepo;
  late HiveFlashcardLoader loader;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(WordAdapter().typeId)) {
      Hive.registerAdapter(WordAdapter());
    }
    if (!Hive.isAdapterRegistered(LearningStatAdapter().typeId)) {
      Hive.registerAdapter(LearningStatAdapter());
    }
    wordRepo = await WordRepository.open();
    learningRepo = await LearningRepository.open();
    loader = HiveFlashcardLoader(wordRepo: wordRepo, learningRepo: learningRepo);
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(WordRepository.boxName);
    await Hive.deleteBoxFromDisk(LearningRepository.boxName);
    await Hive.close();
    await dir.delete(recursive: true);
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
