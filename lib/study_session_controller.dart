import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'flashcard_model.dart';
import 'models/session_log.dart';
import 'services/learning_repository.dart';
import 'services/review_queue_service.dart';
import 'constants.dart';

class StudySessionState {
  final List<Flashcard> words;
  final int targetWords;
  final int targetMinutes;
  final int currentIndex;
  final bool inQuiz;
  final bool finished;
  final DateTime? startTime;
  final List<bool> results;

  StudySessionState({
    required this.words,
    required this.targetWords,
    required this.targetMinutes,
    required this.currentIndex,
    required this.inQuiz,
    required this.finished,
    required this.startTime,
    required this.results,
  });

  factory StudySessionState.initial() => StudySessionState(
        words: const [],
        targetWords: 0,
        targetMinutes: 0,
        currentIndex: 0,
        inQuiz: false,
        finished: false,
        startTime: null,
        results: const [],
      );

  StudySessionState copyWith({
    List<Flashcard>? words,
    int? targetWords,
    int? targetMinutes,
    int? currentIndex,
    bool? inQuiz,
    bool? finished,
    DateTime? startTime,
    List<bool>? results,
  }) {
    return StudySessionState(
      words: words ?? this.words,
      targetWords: targetWords ?? this.targetWords,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      currentIndex: currentIndex ?? this.currentIndex,
      inQuiz: inQuiz ?? this.inQuiz,
      finished: finished ?? this.finished,
      startTime: startTime ?? this.startTime,
      results: results ?? this.results,
    );
  }
}

class StudySessionController extends StateNotifier<StudySessionState> {
  LearningRepository? _learningRepo;
  final Box<SessionLog> _logBox;
  final ReviewQueueService _queueService;
  Timer? _timer;

  StudySessionController(this._logBox, this._queueService)
      : super(StudySessionState.initial());

  Future<LearningRepository> _repo() async {
    _learningRepo ??= await LearningRepository.open();
    return _learningRepo!;
  }

  Future<void> start({
    required List<Flashcard> words,
    required int targetWords,
    required int targetMinutes,
  }) async {
    _timer?.cancel();
    final now = DateTime.now();
    state = StudySessionState(
      words: words.take(targetWords).toList(),
      targetWords: targetWords,
      targetMinutes: targetMinutes,
      currentIndex: 0,
      inQuiz: false,
      finished: false,
      startTime: now,
      results: [],
    );
    if (targetMinutes > 0) {
      _timer = Timer(Duration(minutes: targetMinutes), finish);
    }
  }

  Flashcard? get currentWord {
    if (state.currentIndex >= state.words.length) return null;
    return state.words[state.currentIndex];
  }

  Future<void> answer(bool correct) async {
    final word = currentWord;
    if (word == null) return;
    final repo = await _repo();
    if (!correct) {
      await repo.incrementWrong(word.id);
    }
    await repo.markReviewed(word.id);
    final list = [...state.results, correct];
    state = state.copyWith(results: list);
  }

  Future<void> next() async {
    if (state.finished) return;
    if (!state.inQuiz) {
      state = state.copyWith(inQuiz: true);
    } else {
      final nextIndex = state.currentIndex + 1;
      if (nextIndex >= state.words.length) {
        await finish();
      } else {
        state = state.copyWith(currentIndex: nextIndex, inQuiz: false);
      }
    }
  }

  Future<void> finish() async {
    if (state.finished) return;
    _timer?.cancel();
    final end = DateTime.now();
    final log = SessionLog(
      startTime: state.startTime ?? end,
      endTime: end,
      wordCount: state.words.length,
      correctCount: state.results.where((e) => e).length,
    );
    await _logBox.add(log);
    final wrongIds = <String>[];
    for (int i = 0; i < state.words.length && i < state.results.length; i++) {
      if (!state.results[i]) wrongIds.add(state.words[i].id);
    }
    await _queueService.pushAll(wrongIds);
    state = state.copyWith(finished: true);
  }
}

final studySessionControllerProvider =
    StateNotifierProvider<StudySessionController, StudySessionState>((ref) {
  final box = Hive.box<SessionLog>(sessionLogBoxName);
  final queue = ReviewQueueService();
  return StudySessionController(box, queue);
});
