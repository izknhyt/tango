import 'dart:io';

import 'package:hive/hive.dart';

import '../lib/models/learning_stat.dart';
import '../lib/models/saved_theme_mode.dart';
import '../lib/models/word.dart';
import '../lib/history_entry_model.dart';
import '../lib/models/session_log.dart';
import '../lib/models/review_queue.dart';
import '../lib/models/quiz_stat.dart';
import '../lib/models/bookmark.dart';
import '../lib/models/flashcard_state.dart';

final List<Box<dynamic>> _openedBoxes = [];

/// Initialize Hive for tests.
Future<Directory> initHiveForTests() async {
  final dir = await Directory.systemTemp.createTemp('hive_test_');
  Hive.init(dir.path);

  _registerAdapters();

  return dir;
}

void _registerAdapters() {
  if (!Hive.isAdapterRegistered(WordAdapter().typeId)) {
    Hive.registerAdapter<Word>(WordAdapter());
  }
  if (!Hive.isAdapterRegistered(FlashcardStateAdapter().typeId)) {
    Hive.registerAdapter<FlashcardState>(FlashcardStateAdapter());
  }
  if (!Hive.isAdapterRegistered(HistoryEntryAdapter().typeId)) {
    Hive.registerAdapter<HistoryEntry>(HistoryEntryAdapter());
  }
  if (!Hive.isAdapterRegistered(SessionLogAdapter().typeId)) {
    Hive.registerAdapter<SessionLog>(SessionLogAdapter());
  }
  if (!Hive.isAdapterRegistered(ReviewQueueAdapter().typeId)) {
    Hive.registerAdapter<ReviewQueue>(ReviewQueueAdapter());
  }
  if (!Hive.isAdapterRegistered(BookmarkAdapter().typeId)) {
    Hive.registerAdapter<Bookmark>(BookmarkAdapter());
  }
  if (!Hive.isAdapterRegistered(QuizStatAdapter().typeId)) {
    Hive.registerAdapter<QuizStat>(QuizStatAdapter());
  }
  if (!Hive.isAdapterRegistered(LearningStatAdapter().typeId)) {
    Hive.registerAdapter<LearningStat>(LearningStatAdapter());
  }
  if (!Hive.isAdapterRegistered(SavedThemeModeAdapter().typeId)) {
    Hive.registerAdapter<SavedThemeMode>(SavedThemeModeAdapter());
  }
}

/// Close and delete all Hive boxes used for tests.
Future<void> closeHiveForTests(Directory dir) async {
  for (final box in _openedBoxes.where((b) => b.isOpen)) {
    await box.close();
    await box.deleteFromDisk();
  }
  await Hive.close();
  await dir.delete(recursive: true);
  _openedBoxes.clear();
}
