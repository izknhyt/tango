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
  if (!Hive.isAdapterRegistered(WordAdapter().typeId)) {
    Hive.registerAdapter(WordAdapter());
  }
  if (!Hive.isAdapterRegistered(LearningStatAdapter().typeId)) {
    Hive.registerAdapter(LearningStatAdapter());
  }
  if (!Hive.isAdapterRegistered(SavedThemeModeAdapter().typeId)) {
    Hive.registerAdapter(SavedThemeModeAdapter());
  }
  if (!Hive.isAdapterRegistered(HistoryEntryAdapter().typeId)) {
    Hive.registerAdapter(HistoryEntryAdapter());
  }
  if (!Hive.isAdapterRegistered(ReviewQueueAdapter().typeId)) {
    Hive.registerAdapter(ReviewQueueAdapter());
  }
  if (!Hive.isAdapterRegistered(SessionLogAdapter().typeId)) {
    Hive.registerAdapter(SessionLogAdapter());
  }
  if (!Hive.isAdapterRegistered(BookmarkAdapter().typeId)) {
    Hive.registerAdapter(BookmarkAdapter());
  }
  if (!Hive.isAdapterRegistered(QuizStatAdapter().typeId)) {
    Hive.registerAdapter(QuizStatAdapter());
  }
  if (!Hive.isAdapterRegistered(FlashcardStateAdapter().typeId)) {
    Hive.registerAdapter(FlashcardStateAdapter());
  }
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
