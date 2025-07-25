
/// **Minimal test bootstrap** – uses `hive_test` for temp-dir handling.
/// 1. `setUpTestHive()` creates a fresh tmp dir & calls `Hive.init`
/// 2. `tearDownTestHive()` closes boxes & deletes the dir
///
/// これに合わせて各テストは
/// ```dart
///   final box = await openTypedBox<MyModel>('my_box_v1');
/// ```
/// だけで OK。自前で Hive.openBox / close は不要。


import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';

// 既存ユーティリティ（idempotent open）
import 'package:tango/hive_utils.dart' show openTypedBox;

// ---- アダプタ登録 ------------------------------------------------------------
import 'package:tango/hive_utils.dart' show openTypedBox;
export 'package:tango/hive_utils.dart' show openTypedBox;

import 'package:tango/models/word.dart';
import 'package:tango/models/learning_stat.dart';
import 'package:tango/models/saved_theme_mode.dart';
import 'package:tango/history_entry_model.dart';
import 'package:tango/models/review_queue.dart';
import 'package:tango/models/session_log.dart';
import 'package:tango/models/bookmark.dart';
import 'package:tango/models/flashcard_state.dart';
import 'package:tango/models/quiz_stat.dart';

void _registerAdapters() {
  void r<T>(TypeAdapter<T> a) {
    if (!Hive.isAdapterRegistered(a.typeId)) Hive.registerAdapter(a);
  }

  r<Word>(WordAdapter());
  r<LearningStat>(LearningStatAdapter());
  r<SavedThemeMode>(SavedThemeModeAdapter());
  r<HistoryEntry>(HistoryEntryAdapter());
  r<ReviewQueue>(ReviewQueueAdapter());
  r<SessionLog>(SessionLogAdapter());
  r<Bookmark>(BookmarkAdapter());
  r<FlashcardState>(FlashcardStateAdapter());
  r<QuizStat>(QuizStatAdapter());
}

// ---- global for every test file --------------------------------------------

setUpAll(() async {
  await setUpTestHive();   // tmp dir + Hive.init
  _registerAdapters();
});

tearDownAll(() async => tearDownTestHive());

/// Helper re-export so既存テストでも `import 'test/test_harness.dart';`
/// から openTypedBox が取れる
export 'package:tango/hive_utils.dart' show openTypedBox;

// Note: 旧 `initHiveForTests` / `closeHiveForTests` / `_openTestBoxes` は
//       もう不要なので削除して OK
import 'package:tango/constants.dart';
import 'package:tango/services/learning_repository.dart';
import 'package:tango/services/word_repository.dart';

const wordsBoxName = WordRepository.boxName;
const learningStatBoxName = LearningRepository.boxName;

void _register<T>(TypeAdapter<T> adapter) {
  if (!Hive.isAdapterRegistered(adapter.typeId)) {
    Hive.registerAdapter(adapter);
  }
}

void _registerAdapters() {
  _register(WordAdapter());
  _register(LearningStatAdapter());
  _register(SavedThemeModeAdapter());
  _register(HistoryEntryAdapter());
  _register(ReviewQueueAdapter());
  _register(SessionLogAdapter());
  _register(BookmarkAdapter());
  _register(QuizStatAdapter());
  _register(FlashcardStateAdapter());
}

Future<void> openAllBoxes() async {
  await Future.wait([
    openTypedBox<SavedThemeMode>(settingsBoxName),
    openTypedBox<ReviewQueue>(reviewQueueBoxName),
    openTypedBox<HistoryEntry>(historyBoxName),
    openTypedBox<LearningStat>(learningStatBoxName),
    openTypedBox<SessionLog>(sessionLogBoxName),
    openTypedBox<Bookmark>(bookmarksBoxName),
    openTypedBox<Word>(wordsBoxName),
    openTypedBox<QuizStat>(quizStatsBoxName),
  ]);
}

setUpAll(() async {
  await setUpTestHive();
  _registerAdapters();
});

tearDownAll(() async {
  await tearDownTestHive();
});
