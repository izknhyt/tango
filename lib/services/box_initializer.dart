import 'package:hive/hive.dart';

import '../constants.dart';
import '../history_entry_model.dart';
import '../models/flashcard_state.dart';
import '../models/learning_stat.dart';
import '../models/quiz_stat.dart';
import '../models/review_queue.dart';
import '../models/saved_theme_mode.dart';
import '../models/session_log.dart';
import '../models/word.dart';
import '../models/bookmark.dart';
import 'learning_repository.dart';
import 'word_repository.dart';

Future<Box<T>> _openBoxWithMigration<T>(
  String name,
  HiveAesCipher cipher,
) async {
  try {
    return await Hive.openBox<T>(name, encryptionCipher: cipher);
  } catch (_) {
    try {
      final box = await Hive.openBox<T>(name);
      final data = Map<dynamic, T>.from(box.toMap());
      await box.close();
      await box.deleteFromDisk();
      final newBox = await Hive.openBox<T>(name, encryptionCipher: cipher);
      await newBox.putAll(data);
      return newBox;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to open unencrypted box $name: $e');
      await Hive.deleteBoxFromDisk(name);
      return Hive.openBox<T>(name, encryptionCipher: cipher);
    }
  }
}

/// Open all Hive boxes used by the application.
Future<void> openAllBoxes(HiveAesCipher cipher) async {
  final tasks = [
    _openBoxWithMigration<Map>(favoritesBoxName, cipher),
    _openBoxWithMigration<HistoryEntry>(historyBoxName, cipher),
    _openBoxWithMigration<QuizStat>(quizStatsBoxName, cipher),
    _openBoxWithMigration<FlashcardState>(flashcardStateBoxName, cipher),
    _openBoxWithMigration<Word>(WordRepository.boxName, cipher),
    _openBoxWithMigration<LearningStat>(LearningRepository.boxName, cipher),
    _openBoxWithMigration<SessionLog>(sessionLogBoxName, cipher),
    _openBoxWithMigration<ReviewQueue>(reviewQueueBoxName, cipher),
    _openBoxWithMigration<SavedThemeMode>(settingsBoxName, cipher),
    _openBoxWithMigration<Bookmark>(bookmarksBoxName, cipher),
  ];
  await Future.wait(tasks);
}
