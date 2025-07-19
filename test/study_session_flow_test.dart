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
import 'package:tango/history_entry_model.dart';
import 'package:tango/services/review_queue_service.dart';
import 'package:tango/services/learning_repository.dart';
import 'package:tango/flashcard_repository_provider.dart';
import 'package:tango/study_session_controller.dart';
import 'package:tango/study_start_sheet.dart';
import 'fakes/fake_flashcard_repository.dart';
import 'test_harness.dart';

void main() {
  late Directory hiveTempDir;

  setUpAll(() async {
    hiveTempDir = await initHiveForTests();
    await openAllBoxes();
  });

  tearDownAll(() async {
    await closeHiveForTests(hiveTempDir);
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
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionControllerProvider.overrideWith((ref) {
            final logBox = Hive.box<SessionLog>(sessionLogBoxName);
            final queueBox = Hive.box<ReviewQueue>(reviewQueueBoxName);
            return StudySessionController(logBox, ReviewQueueService(queueBox));
          }),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository([_card('0')]),
          )
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

    final startFinder = find.text('start');
    expect(startFinder, findsOneWidget);
    await tester.tap(startFinder);
    await tester.pumpAndSettle();

    final beginFinder = find.text('開始');
    expect(beginFinder, findsOneWidget);
    await tester.tap(beginFinder);
    await tester.pumpAndSettle();

    expect(find.byType(StudySessionScreen), findsOneWidget);
  });
}
