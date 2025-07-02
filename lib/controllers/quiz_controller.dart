import 'dart:math';
import 'package:flutter/foundation.dart';

import '../flashcard_model.dart';
import '../quiz_setup_screen.dart';
import '../services/learning_repository.dart';
import '../services/review_queue_service.dart';

class QuizController extends ChangeNotifier {
  final List<Flashcard> words;
  final int totalQuestions;
  final QuizType quizType;

  LearningRepository? _learningRepo;
  final ReviewQueueService _queueService;

  List<Flashcard>? _allWords;
  int _currentIndex = 0;
  int _score = 0;
  final List<bool> _answerResults = [];
  late DateTime _startTime;
  late Flashcard _currentFlashcard;
  List<Flashcard> _choices = [];
  bool _answered = false;
  String? _selectedTerm;

  QuizController({
    required this.words,
    required this.totalQuestions,
    required this.quizType,
    ReviewQueueService? queueService,
  }) : _queueService = queueService ?? ReviewQueueService() {
    _startTime = DateTime.now();
    _loadQuestion();
  }

  Future<LearningRepository> _repo() async {
    _learningRepo ??= await LearningRepository.open();
    return _learningRepo!;
  }

  void setAllWords(List<Flashcard> list) {
    _allWords = list;
    _generateChoices();
    notifyListeners();
  }

  List<Flashcard> _getAllWords() {
    return _allWords ?? words;
  }

  void _generateChoices() {
    final all = _getAllWords();
    final pool = List<Flashcard>.from(all)
      ..removeWhere((e) => e.id == _currentFlashcard.id);
    pool.shuffle(Random());
    final incorrect = pool.take(3).toList();
    _choices = [_currentFlashcard, ...incorrect]..shuffle(Random());
  }

  void _loadQuestion() {
    _currentFlashcard = words[_currentIndex];
    _generateChoices();
    _answered = false;
    _selectedTerm = null;
  }

  Future<void> _recordAnswer(bool correct) async {
    final repo = await _repo();
    final id = _currentFlashcard.id;
    if (correct) {
      await repo.incrementCorrect(id);
      await _queueService.clearWeak(id);
    } else {
      await repo.incrementWrong(id);
      await _queueService.push(id);
    }
    await repo.markReviewed(id);
  }

  Future<void> select(String term) async {
    if (_answered) return;
    _selectedTerm = term;
    final correct = term == _currentFlashcard.term;
    if (correct) _score++;
    _answerResults.add(correct);
    await _recordAnswer(correct);
    _answered = true;
    notifyListeners();
  }

  void next() {
    if (_currentIndex + 1 >= totalQuestions) return;
    _currentIndex++;
    _loadQuestion();
    notifyListeners();
  }

  Flashcard get currentFlashcard => _currentFlashcard;
  List<Flashcard> get choices => _choices;
  bool get answered => _answered;
  int get currentIndex => _currentIndex;
  int get score => _score;
  String? get selectedTerm => _selectedTerm;
  List<bool> get answerResults => List.unmodifiable(_answerResults);
  DateTime get startTime => _startTime;
}
