import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:tango/flashcard_model.dart';
import 'package:tango/models/session_log.dart';
import 'package:tango/models/learning_stat.dart';
import 'package:tango/models/review_queue.dart';
import 'package:tango/study_session_controller.dart';
import 'package:tango/constants.dart';
import 'package:tango/services/review_queue_service.dart';
import 'package:tango/services/learning_repository.dart';
import 'test_harness.dart' hide setUpAll;

void main() {
  late Directory hiveTempDir;
  late Box<SessionLog> logBox;
  late Box<LearningStat> statBox;
  late Box<ReviewQueue> boxQueue;
  late StudySessionController controller;

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

  setUpAll(() async {
    hiveTempDir = await initHiveForTests();
    if (!Hive.isBoxOpen(sessionLogBoxName)) {
      await Hive.openBox<SessionLog>(sessionLogBoxName);
    }
    await LearningRepository.open();
    await ReviewQueueService.open();
    logBox = Hive.box<SessionLog>(sessionLogBoxName);
    statBox = Hive.box<LearningStat>(LearningRepository.boxName);
    boxQueue = Hive.box<ReviewQueue>(reviewQueueBoxName);
    controller = StudySessionController(logBox, ReviewQueueService(boxQueue));
  });

  tearDownAll(() async {
    await closeHiveForTests(hiveTempDir);
  });

  test('progresses through states', () async {
    await controller.start(words: [_card('1')], targetWords: 1, targetMinutes: 0);
    expect(controller.state.currentIndex, 0);
    expect(controller.state.inQuiz, false);

    await controller.next();
    expect(controller.state.inQuiz, true);

    await controller.answer(true);
    await controller.next();
    expect(controller.state.finished, true);
    expect(logBox.length, 1);
  });
}
