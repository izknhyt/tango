import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:tango/constants.dart';
import 'package:tango/flashcard_model.dart';
import 'package:tango/models/learning_stat.dart';
import 'package:tango/models/session_log.dart';
import 'package:tango/services/review_queue_service.dart';
import 'package:tango/study_session_controller.dart';
import 'package:tango/study_start_sheet.dart';

void main() {
  setUpAll(() async {
    Hive.init('./testdb');
    Hive.registerAdapter(SessionLogAdapter());
    Hive.registerAdapter(LearningStatAdapter());
    Hive.registerAdapter(ReviewQueueAdapter());
    await Hive.openBox<SessionLog>(sessionLogBoxName);
    await Hive.openBox<LearningStat>(LearningRepository.boxName);
    await Hive.openBox(reviewQueueBoxName);
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk(sessionLogBoxName);
    await Hive.deleteBoxFromDisk(LearningRepository.boxName);
    await Hive.deleteBoxFromDisk(reviewQueueBoxName);
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

  testWidgets('flow one word', (tester) async {
    final words = [_card('1')];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionControllerProvider.overrideWith((ref) {
            final logBox = Hive.box<SessionLog>(sessionLogBoxName);
            final queueBox = Hive.box(reviewQueueBoxName);
            return StudySessionController(logBox, ReviewQueueService(queueBox));
          })
        ],
        child: const MaterialApp(home: Scaffold()),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
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
