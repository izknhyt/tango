import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:tango/constants.dart';
import 'package:tango/flashcard_model.dart';
import 'package:tango/models/learning_stat.dart';
import 'package:tango/models/session_log.dart';
import 'package:tango/models/review_queue.dart';
import 'package:tango/services/review_queue_service.dart';
import 'package:tango/services/learning_repository.dart';
import 'package:tango/services/flashcard_loader.dart';
import 'package:tango/flashcard_repository.dart';
import 'package:tango/flashcard_repository_provider.dart';
import 'package:tango/study_session_controller.dart';
import 'package:tango/study_start_sheet.dart';

void main() {
  late Directory dir;
  late Box<SessionLog> logBox;
  late Box<LearningStat> statBox;
  late Box<ReviewQueue> queueBox;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    Hive.registerAdapter(SessionLogAdapter());
    Hive.registerAdapter(LearningStatAdapter());
    Hive.registerAdapter(ReviewQueueAdapter());
    logBox = await Hive.openBox<SessionLog>(sessionLogBoxName);
    statBox = await Hive.openBox<LearningStat>(LearningRepository.boxName);
    queueBox = await Hive.openBox<ReviewQueue>(reviewQueueBoxName);
  });

  tearDownAll(() async {
    await logBox.close();
    await statBox.close();
    await queueBox.close();
    await Hive.deleteBoxFromDisk(sessionLogBoxName);
    await Hive.deleteBoxFromDisk(LearningRepository.boxName);
    await Hive.deleteBoxFromDisk(reviewQueueBoxName);
    await dir.delete(recursive: true);
  });

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

  class _FakeLoader implements FlashcardLoader {
    final List<Flashcard> cards;
    _FakeLoader(this.cards);

    @override
    Future<List<Flashcard>> loadAll() async => cards;
  }

  testWidgets('flow one word', (tester) async {
    final words = [_card('1')];
    final repo = FlashcardRepository(loader: _FakeLoader(words));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWith((ref) => repo),
          studySessionControllerProvider.overrideWith(
            (ref) => StudySessionController(
              logBox,
              ReviewQueueService(queueBox),
            ),
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showStudyStartSheet(context),
                child: const Text('start'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('start'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('開始'));
    await tester.pumpAndSettle();

    expect(find.byType(StudySessionScreen), findsOneWidget);
  });
}
