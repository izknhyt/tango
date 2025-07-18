import 'dart:io';

import 'package:hive/hive.dart';

import '../lib/models/learning_stat.dart';
import '../lib/models/saved_theme_mode.dart';
import '../lib/models/word.dart';
import '../lib/constants.dart';
import '../lib/services/learning_repository.dart';
import '../lib/services/word_repository.dart';

final List<Box<dynamic>> _openedBoxes = [];

/// Initialize Hive for tests and open all required boxes.
Future<Directory> initHiveForTests() async {
  final dir = await Directory.systemTemp.createTemp('hive_test_');
  Hive.init(dir.path);

  // Register all adapters once
  if (!Hive.isAdapterRegistered(SavedThemeModeAdapter().typeId)) {
    Hive.registerAdapter(SavedThemeModeAdapter());
    Hive.registerAdapter(LearningStatAdapter());
    Hive.registerAdapter(WordAdapter());
    // add more here if needed
  }

  // The boxes we need in every test
  const boxNames = [
    settingsBoxName,
    reviewQueueBoxName,
    historyBoxName,
    LearningRepository.boxName,
    sessionLogBoxName,
    favoritesBoxName,
    WordRepository.boxName,
    bookmarksBoxName,
    quizStatsBoxName,
  ];

  for (final name in boxNames) {
    if (!Hive.isBoxOpen(name)) {
      _openedBoxes.add(await Hive.openBox(name));
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
