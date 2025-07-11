import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:tango/constants.dart';
import 'package:tango/history_entry_model.dart';
import 'package:tango/models/flashcard_state.dart';
import 'package:tango/models/learning_stat.dart';
import 'package:tango/models/quiz_stat.dart';
import 'package:tango/models/review_queue.dart';
import 'package:tango/models/saved_theme_mode.dart';
import 'package:tango/models/session_log.dart';
import 'package:tango/models/word.dart';
import 'package:tango/models/bookmark.dart';
import 'package:tango/services/box_initializer.dart';
import 'package:tango/services/learning_repository.dart';
import 'package:tango/services/word_repository.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    final adapters = [
      HistoryEntryAdapter(),
      WordAdapter(),
      LearningStatAdapter(),
      QuizStatAdapter(),
      SessionLogAdapter(),
      ReviewQueueAdapter(),
      SavedThemeModeAdapter(),
      FlashcardStateAdapter(),
      BookmarkAdapter(),
    ];
    for (final adapter in adapters) {
      if (!Hive.isAdapterRegistered(adapter.typeId)) {
        Hive.registerAdapter(adapter);
      }
    }
  });

  tearDown(() async {
    final boxes = [
      favoritesBoxName,
      historyBoxName,
      quizStatsBoxName,
      flashcardStateBoxName,
      WordRepository.boxName,
      LearningRepository.boxName,
      sessionLogBoxName,
      reviewQueueBoxName,
      settingsBoxName,
      bookmarksBoxName,
    ];
    for (final name in boxes) {
      if (await Hive.boxExists(name)) {
        await Hive.deleteBoxFromDisk(name);
      }
    }
    await dir.delete(recursive: true);
  });

  test('openAllBoxes opens each required Hive box', () async {
    final cipher = HiveAesCipher(Hive.generateSecureKey());
    await openAllBoxes(cipher);

    expect(Hive.isBoxOpen(favoritesBoxName), isTrue);
    expect(Hive.isBoxOpen(historyBoxName), isTrue);
    expect(Hive.isBoxOpen(quizStatsBoxName), isTrue);
    expect(Hive.isBoxOpen(flashcardStateBoxName), isTrue);
    expect(Hive.isBoxOpen(WordRepository.boxName), isTrue);
    expect(Hive.isBoxOpen(LearningRepository.boxName), isTrue);
    expect(Hive.isBoxOpen(sessionLogBoxName), isTrue);
    expect(Hive.isBoxOpen(reviewQueueBoxName), isTrue);
    expect(Hive.isBoxOpen(settingsBoxName), isTrue);
    expect(Hive.isBoxOpen(bookmarksBoxName), isTrue);
  });

  test('openAllBoxes recovers when both opens fail', () async {
    final cipher = HiveAesCipher(Hive.generateSecureKey());
    final file = File('${dir.path}/$favoritesBoxName.hive');
    await file.writeAsString('junk');

    await openAllBoxes(cipher);

    expect(Hive.isBoxOpen(favoritesBoxName), isTrue);
  });
}
