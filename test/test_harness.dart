import 'dart:io';

import 'package:hive/hive.dart';

import '../lib/constants.dart';
import '../lib/history_entry_model.dart';
import '../lib/models/bookmark.dart';
import '../lib/models/flashcard_state.dart';
import '../lib/models/learning_stat.dart';
import '../lib/models/quiz_stat.dart';
import '../lib/models/review_queue.dart';
import '../lib/models/saved_theme_mode.dart';
import '../lib/models/session_log.dart';
import '../lib/models/word.dart';
import '../lib/services/learning_repository.dart';
import '../lib/services/word_repository.dart';

/// Initialize Hive for tests and open all required boxes.
Future<Directory> initHiveForTests() async {
  final dir = await Directory.systemTemp.createTemp();
  Hive.init(dir.path);
  final adapters = <TypeAdapter<dynamic>>[
    SavedThemeModeAdapter(),
    ReviewQueueAdapter(),
    HistoryEntryAdapter(),
    SessionLogAdapter(),
    LearningStatAdapter(),
    WordAdapter(),
    QuizStatAdapter(),
    FlashcardStateAdapter(),
    BookmarkAdapter(),
  ];
  for (final adapter in adapters) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }
  await Hive.openBox<SavedThemeMode>(settingsBoxName);
  await Hive.openBox<ReviewQueue>(reviewQueueBoxName);
  await Hive.openBox<HistoryEntry>(historyBoxName);
  await Hive.openBox<SessionLog>(sessionLogBoxName);
  await Hive.openBox<LearningStat>(LearningRepository.boxName);
  await Hive.openBox<Map>(favoritesBoxName);
  await Hive.openBox<QuizStat>(quizStatsBoxName);
  await Hive.openBox<Word>(WordRepository.boxName);
  await Hive.openBox<Bookmark>(bookmarksBoxName);
  await Hive.openBox<FlashcardState>(flashcardStateBoxName);
  return dir;
}

/// Close and delete all Hive boxes used for tests.
Future<void> closeHiveForTests(Directory dir) async {
  for (final box in Hive.boxes.values) {
    await box.close();
    await box.deleteFromDisk();
  }
  await Hive.close();
  await dir.delete(recursive: true);
}
