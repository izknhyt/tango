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

  final adapters = [
    WordAdapter(),
    FlashcardStateAdapter(),
    HistoryEntryAdapter(),
    SessionLogAdapter(),
    ReviewQueueAdapter(),
    BookmarkAdapter(),
    QuizStatAdapter(),
    LearningStatAdapter(),
    SavedThemeModeAdapter(),
  ];

  for (final adapter in adapters) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  return dir;
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
