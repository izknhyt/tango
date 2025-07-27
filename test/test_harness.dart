import 'dart:io';
import 'package:flutter_test/flutter_test.dart' as ft;
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

void initTestHarness() {
  ft.setUpAll(() async {
    _tempDir = await Directory.systemTemp.createTemp();
    Hive.init(_tempDir!.path);
    _registerAdapters();

    // Open boxes with their explicit types
    await Hive.openBox<Word>(WordRepository.boxName);
    await Hive.openBox<LearningStat>(LearningRepository.boxName);
    await Hive.openBox<SessionLog>(sessionLogBoxName);
    await Hive.openBox<HistoryEntry>(historyBoxName);
    await Hive.openBox<ReviewQueue>(reviewQueueBoxName);
    await Hive.openBox<Bookmark>(bookmarksBoxName);
    await Hive.openBox<QuizStat>(quizStatsBoxName);
    await Hive.openBox<FlashcardState>(flashcardStateBoxName);
    await Hive.openBox<SavedThemeMode>(settingsBoxName);
    await Hive.openBox<Map>(favoritesBoxName);
  });

  ft.tearDownAll(() async {
    await Hive.close();
    if (_tempDir != null) {
      await _tempDir!.delete(recursive: true);
    }
  });
}
