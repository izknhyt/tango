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

final List<Box> _openedBoxes = [];

/// Initialize Hive for tests and open all required boxes.
Future<Directory> initHiveForTests() async {
  final dir = await Directory.systemTemp.createTemp();
  Hive.init(dir.path);
  final savedThemeModeAdapter = SavedThemeModeAdapter();
  if (!Hive.isAdapterRegistered(savedThemeModeAdapter.typeId)) {
    Hive.registerAdapter(savedThemeModeAdapter);
  }
  _openedBoxes.clear();
  final settingsBox =
      await Hive.openBox<SavedThemeMode>(settingsBoxName);
  final queueBox = await Hive.openBox<ReviewQueue>(reviewQueueBoxName);
  final historyBox = await Hive.openBox<HistoryEntry>(historyBoxName);
  _openedBoxes.addAll([settingsBox, queueBox, historyBox]);
  return dir;
}

/// Close and delete all Hive boxes used for tests.
Future<void> closeHiveForTests(Directory dir) async {
  for (final box in _openedBoxes) {
    await box.close();
    await box.deleteFromDisk();
  }
  await Hive.close();
  await dir.delete(recursive: true);
}
