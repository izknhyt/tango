import 'dart:io';

import 'package:flutter_test/flutter_test.dart' as ft;
import 'package:hive/hive.dart';


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
import 'package:tango/services/learning_repository.dart';
import 'package:tango/services/word_repository.dart';

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

    // ☆☆☆ ここが最後の最重要修正点 ☆☆☆
    // 型を明記してBoxを開く
    await Hive.openBox<Word>(wordsBoxName);
    await Hive.openBox<LearningStat>(learningStatBoxName);
    await Hive.openBox<SessionLog>(sessionLogBoxName);
    await Hive.openBox<HistoryEntry>(historyBoxName);
    await Hive.openBox<ReviewQueue>(reviewQueueBoxName);
    await Hive.openBox<Bookmark>(bookmarksBoxName);
    await Hive.openBox<QuizStat>(quizStatsBoxName);
    await Hive.openBox<FlashcardState>(flashcardStateBoxName);

    // 型がないBoxはそのまま開く
    await Hive.openBox(settingsBoxName);
    await Hive.openBox(favoritesBoxName);
  });

  ft.tearDownAll(() async {
    await Hive.close();
    if (_tempDir != null) {
      await _tempDir!.delete(recursive: true);
    }
  });
}
