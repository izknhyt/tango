import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';

// Re-export openTypedBox for test files
import 'package:tango/hive_utils.dart' show openTypedBox;
export 'package:tango/hive_utils.dart' show openTypedBox;

// Model adapters
import 'package:tango/models/word.dart';
import 'package:tango/models/learning_stat.dart';
import 'package:tango/models/saved_theme_mode.dart';
import 'package:tango/history_entry_model.dart';
import 'package:tango/models/review_queue.dart';
import 'package:tango/models/session_log.dart';
import 'package:tango/models/bookmark.dart';
import 'package:tango/models/flashcard_state.dart';
import 'package:tango/models/quiz_stat.dart';

// Constants and repository names
import 'package:tango/constants.dart';
import 'package:tango/services/learning_repository.dart';
import 'package:tango/services/word_repository.dart';

// Provide box names for words and learning stats
const wordsBoxName = WordRepository.boxName;
const learningStatBoxName = LearningRepository.boxName;

/// Safely register a single adapter if it isn't already registered.
void _register(TypeAdapter adapter) {
  if (!Hive.isAdapterRegistered(adapter.typeId)) {
    Hive.registerAdapter(adapter);
  }
}

/// Register all Hive type adapters used by the app.
/// Each adapter is registered only once.
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

/// Open all persistent boxes used in the app. This helper can be called from tests
/// that need multiple boxes to be open at once.
Future<void> openAllBoxes() async {
  await Future.wait([
    openTypedBox(settingsBoxName),
    openTypedBox(reviewQueueBoxName),
    openTypedBox(historyBoxName),
    openTypedBox(learningStatBoxName),
    openTypedBox(sessionLogBoxName),
    openTypedBox(bookmarksBoxName),
    openTypedBox(wordsBoxName),
    openTypedBox(quizStatsBoxName),
  ]);
}

/// Global setup for tests.
/// Initializes Hive in a temporary directory and registers all adapters.
setUpAll(() async {
  await setUpTestHive();
  _registerAdapters();
});

/// Global teardown for tests.
/// Closes Hive and cleans up the temporary directory.
tearDownAll(() async => tearDownTestHive());
