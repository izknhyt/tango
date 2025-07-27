import 'dart:io';

import 'package:flutter_test/flutter_test.dart' as ft;
import 'package:hive/hive.dart';

import 'package:tango/hive_utils.dart' show openTypedBox;
export 'package:tango/hive_utils.dart' show openTypedBox;

// 全てのモデルとアダプターをインポート
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

// アダプター登録をまとめた関数
void _registerAdapters() {
  void _register(TypeAdapter adapter) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

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

Directory? _tempDir;

// 唯一のセットアップ関数
void initTestHarness() {
  ft.setUpAll(() async {
    _tempDir = await Directory.systemTemp.createTemp();
    Hive.init(_tempDir!.path);

    _registerAdapters();

    // ここで全てのBoxを開いてしまう
    await Future.wait([
      openTypedBox(settingsBoxName),
      openTypedBox(reviewQueueBoxName),
      openTypedBox(historyBoxName),
      openTypedBox(learningStatBoxName),
      openTypedBox(sessionLogBoxName),
      openTypedBox(bookmarksBoxName),
      openTypedBox(wordsBoxName),
      openTypedBox(quizStatsBoxName),
      openTypedBox(flashcardStateBoxName),
      openTypedBox(favoritesBoxName),
    ]);
  });

  ft.tearDownAll(() async {
    await Hive.close();
    if (_tempDir != null) {
      await _tempDir!.delete(recursive: true);
    }
  });
}
