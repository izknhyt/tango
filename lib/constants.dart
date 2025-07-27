import 'services/learning_repository.dart';
import 'services/word_repository.dart';

const String favoritesBoxName = 'favorites_box_v2';
const String historyBoxName = 'history_box_v2';
const String quizStatsBoxName = 'quiz_stats_box_v1';
const String flashcardStateBoxName = 'flashcard_state_box';
const String sessionLogBoxName = 'session_log_box_v1';
const String reviewQueueBoxName = 'review_queue_box_v1';
const String settingsBoxName = 'settings_box';
const String bookmarksBoxName = 'bookmarks_box_v1';

const String learningStatBoxName = LearningRepository.boxName;
const String wordsBoxName = WordRepository.boxName;

// 端末サイズ判定用のブレークポイント (単位: dp)
const double kTabletBreakpoint = 600.0;
