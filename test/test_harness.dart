import 'dart:io';

import 'package:hive/hive.dart';
import 'package:flutter_test/flutter_test.dart';

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

/// Helper: open a Hive box *idempotently*.
///  - If the box is already open, just return the in-memory instance (Hive.box<T>).
///  - Otherwise open it first (Hive.openBox<T>).
///
/// Technical reason:
/// Dart’s parser was choking on the call to `openTypedBox<...>()`
/// because that function did not exist yet; the missing identifier
/// caused the “Expected an identifier, but got '('" error to surface on
/// the next line (`setUpAll`).  Defining this helper (and using it in
/// `_openAllBoxes`) gives the parser a valid symbol to resolve *and*
/// removes the risk of “Box already open” / “Box not found” at runtime,
/// since it re-uses an existing box when present.
Future<Box<T>> openTypedBox<T>(String boxName) async =>
    Hive.isBoxOpen(boxName) ? Hive.box<T>(boxName) : await Hive.openBox<T>(boxName);

/// Opens the Hive boxes that unit tests expect.
Future<void> _openTestBoxes() async {
  await Future.wait([
    Hive.openBox<dynamic>('bookmark_box'),
    Hive.openBox<dynamic>('history_box_v2'),
  ]);
}

final List<Box<dynamic>> _openedBoxes = [];

const wordsBoxName = WordRepository.boxName;
const learningStatBoxName = LearningRepository.boxName;

void _register<T>(TypeAdapter<T> adapter) {
  if (!Hive.isAdapterRegistered(adapter.typeId)) {
    Hive.registerAdapter(adapter);
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
    openTypedBox<SavedThemeMode>('settings_box'),
    openTypedBox<ReviewQueue>('review_queue_box_v1'),
    openTypedBox<HistoryEntry>('history_box_v2'),
    openTypedBox<LearningStat>('learning_stat_box_v1'),
    openTypedBox<SessionLog>('session_log_box_v1'),
    openTypedBox<Bookmark>('bookmarks_box_v1'),
    openTypedBox<Word>('words_box_v1'),
    openTypedBox<QuizStat>('quiz_stats_box_v1'),
  ]);
}

setUpAll(() async {
  Hive.initMemory();

  _register<Word>(WordAdapter());
  _register<LearningStat>(LearningStatAdapter());
  _register<SavedThemeMode>(SavedThemeModeAdapter());
  _register<HistoryEntry>(HistoryEntryAdapter());
  _register<ReviewQueue>(ReviewQueueAdapter());
  _register<SessionLog>(SessionLogAdapter());
  _register<Bookmark>(BookmarkAdapter());
  _register<QuizStat>(QuizStatAdapter());
  _register<FlashcardState>(FlashcardStateAdapter());

  await _openTestBoxes();
});
