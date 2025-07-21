import 'dart:io';

import 'package:hive/hive.dart';

import 'package:tango/models/word.dart';
import 'package:tango/models/learning_stat.dart';
import 'package:tango/models/saved_theme_mode.dart';
import 'package:tango/history_entry_model.dart';
import 'package:tango/models/review_queue.dart';
import 'package:tango/models/session_log.dart';
import 'package:tango/models/bookmark.dart';
import 'package:tango/models/flashcard_state.dart';
import 'package:tango/models/quiz_stat.dart';
import 'package:tango/constants.dart';
import 'package:tango/services/learning_repository.dart';
import 'package:tango/services/word_repository.dart';

final List<Box<dynamic>> _openedBoxes = [];

const wordsBoxName = WordRepository.boxName;
const learningStatBoxName = LearningRepository.boxName;

void _register<T>(TypeAdapter<T> adapter) {
  if (!Hive.isAdapterRegistered(adapter.typeId)) {
    Hive.registerAdapter<T>(adapter);
  }
}

/// Initialize Hive for tests.
Future<Directory> initHiveForTests() async {
  final dir = await Directory.systemTemp.createTemp('hive_test_');
  Hive.init(dir.path);

  _register<Word>(WordAdapter());
  _register<LearningStat>(LearningStatAdapter());
  _register<SavedThemeMode>(SavedThemeModeAdapter());
  _register<HistoryEntry>(HistoryEntryAdapter());
  _register<ReviewQueue>(ReviewQueueAdapter());
  _register<SessionLog>(SessionLogAdapter());
  _register<Bookmark>(BookmarkAdapter());

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

Future<void> openAllBoxes() async {
  if (!Hive.isAdapterRegistered(WordAdapter().typeId)) {
    // 念のため。テスト前に必ず登録される想定だがダブルチェック。
    _register<Word>(WordAdapter());
    _register<LearningStat>(LearningStatAdapter());
    _register<SavedThemeMode>(SavedThemeModeAdapter());
    _register<HistoryEntry>(HistoryEntryAdapter());
    _register<ReviewQueue>(ReviewQueueAdapter());
    _register<SessionLog>(SessionLogAdapter());
    _register<Bookmark>(BookmarkAdapter());
    _register<QuizStat>(QuizStatAdapter());
    _register<FlashcardState>(FlashcardStateAdapter());
  }

  await Future.wait([
    Hive.openBox<SavedThemeMode>('settings_box'),
    Hive.openBox<ReviewQueue>('review_queue_box_v1'),
    Hive.openBox<HistoryEntry>('history_box_v2'),
    Hive.openBox<LearningStat>('learning_stat_box_v1'),
    Hive.openBox<SessionLog>('session_log_box_v1'),
    Hive.openBox<Bookmark>('bookmarks_box_v1'),
    Hive.openBox<Word>('words_box_v1'),
    Hive.openBox<QuizStat>('quiz_stats_box_v1'),
  ]);
}
