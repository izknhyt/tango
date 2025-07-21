import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:tango/flashcard_model.dart';
import 'package:tango/quick_quiz_screen.dart';
import 'package:tango/quiz_in_progress_screen.dart';
import 'package:tango/quiz_setup_screen.dart';
import 'package:tango/models/review_queue.dart';
import 'package:tango/models/learning_stat.dart';
import 'package:tango/models/word.dart';
import 'package:tango/services/review_queue_service.dart';
import 'package:tango/services/learning_repository.dart';
import 'package:tango/services/word_repository.dart';
import 'package:tango/flashcard_repository.dart';
import 'package:tango/flashcard_repository_provider.dart';
import 'package:tango/services/flashcard_loader.dart';
import 'package:tango/constants.dart';
import 'test_harness.dart' hide setUpAll;

class _FakeLoader implements FlashcardLoader {
  final List<Flashcard> cards;
  _FakeLoader(this.cards);

  @override
  Future<List<Flashcard>> loadAll() async => cards;
}

void main() {
  late Directory hiveTempDir;
  late Box<ReviewQueue> queueBox;
  late Box<Map> favBox;
  late Box<LearningStat> statBox;
  late Box<Word> wordBox;
  late ReviewQueueService service;
  late FlashcardRepository repo;

  Flashcard _card(String id) => Flashcard(
        id: id,
        term: id,
        reading: id,
        description: 'd',
        categoryLarge: 'A',
        categoryMedium: 'B',
        categorySmall: 'C',
        categoryItem: 'D',
        importance: 1,
      );

  Word _word(String id) => Word(
        id: id,
        term: id,
        reading: id,
        description: 'd',
        categoryLarge: 'A',
        categoryMedium: 'B',
        categorySmall: 'C',
        categoryItem: 'D',
        importance: 1,
      );

  setUpAll(() async {
    hiveTempDir = await initHiveForTests();
    if (!Hive.isBoxOpen(reviewQueueBoxName)) {
      await Hive.openBox<ReviewQueue>(reviewQueueBoxName);
    }
    if (!Hive.isBoxOpen(favoritesBoxName)) {
      await Hive.openBox<Map>(favoritesBoxName);
    }
    if (!Hive.isBoxOpen(LearningRepository.boxName)) {
      await Hive.openBox<LearningStat>(LearningRepository.boxName);
    }
    if (!Hive.isBoxOpen(WordRepository.boxName)) {
      await Hive.openBox<Word>(WordRepository.boxName);
    }
    queueBox = Hive.box<ReviewQueue>(reviewQueueBoxName);
    favBox = Hive.box<Map>(favoritesBoxName);
    statBox = Hive.box<LearningStat>(LearningRepository.boxName);
    wordBox = Hive.box<Word>(WordRepository.boxName);
    await wordBox.put('0', _word('0'));
    service = ReviewQueueService(queueBox);
    repo = FlashcardRepository(loader: _FakeLoader([_card('0')]));
  });

  tearDown(() async {
    await queueBox.clear();
    await favBox.clear();
    await statBox.clear();
    await wordBox.clear();
  });

  tearDownAll(() async {
    await closeHiveForTests(hiveTempDir);
  });

  testWidgets('weak button disabled when queue empty', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(home: QuickQuizScreen()),
      ),
    );
    await tester.pumpAndSettle();
    final weakFinder = find.text('WEAK');
    final textWidget = tester.widget<Text>(weakFinder);
    final disableColor = Theme.of(tester.element(weakFinder)).disabledColor;
    expect(textWidget.style?.color, disableColor);
  });

  testWidgets('wrong answer adds word to queue', (tester) async {
    final cards = [
      _card('1'),
      _card('2'),
      _card('3'),
      _card('4'),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          home: QuizInProgressScreen(
            quizSessionWords: cards,
            totalSessionQuestions: 1,
            quizSessionType: QuizType.multipleChoice,
          ),
        ),
      ),
    );
    await tester.pump();

    final answer2Finder = find.text('2');
    expect(answer2Finder, findsOneWidget);
    await tester.tap(answer2Finder);
    await tester.pumpAndSettle();

    final q = queueBox.get('queue');
    expect(q?.wordIds, contains('1'));
  });

  testWidgets('correct answer removes word from queue', (tester) async {
    await service.push('1');
    final cards = [
      _card('1'),
      _card('2'),
      _card('3'),
      _card('4'),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          home: QuizInProgressScreen(
            quizSessionWords: cards,
            totalSessionQuestions: 1,
            quizSessionType: QuizType.multipleChoice,
          ),
        ),
      ),
    );
    await tester.pump();

    final answer1Finder = find.text('1');
    expect(answer1Finder, findsOneWidget);
    await tester.tap(answer1Finder);
    await tester.pumpAndSettle();

    final q = queueBox.get('queue');
    expect(q?.wordIds.contains('1'), false);
  });
}
