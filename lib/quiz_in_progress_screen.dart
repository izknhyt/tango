import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'flashcard_model.dart';
import 'flashcard_repository.dart';
import 'quiz_setup_screen.dart';
import 'quiz_result_screen.dart';
import 'star_color.dart';
import 'constants.dart';
import 'services/learning_repository.dart';
import 'services/review_queue_service.dart';

class QuizInProgressScreen extends StatefulWidget {
  final List<Flashcard> quizSessionWords;
  final int totalSessionQuestions;
  final QuizType quizSessionType;

  const QuizInProgressScreen({
    Key? key,
    required this.quizSessionWords,
    required this.totalSessionQuestions,
    required this.quizSessionType,
  }) : super(key: key);

  @override
  State<QuizInProgressScreen> createState() => _QuizInProgressScreenState();
}

class _QuizInProgressScreenState extends State<QuizInProgressScreen> {
  late Box<Map> _favoritesBox;
  List<Flashcard>? _allWords;
  int _currentIndex = 0;
  int _score = 0;
  List<bool> _answerResults = [];

  late Flashcard _currentFlashcard;
  List<Flashcard> _choices = [];
  bool _answered = false;
  String? _selectedTerm;

  final Map<String, Map<StarColor, bool>> _favoriteStatusMap = {};
  late DateTime _startTime;
  LearningRepository? _learningRepo;
  late ReviewQueueService _queueService;

  Future<LearningRepository> _repo() async {
    _learningRepo ??= await LearningRepository.open();
    return _learningRepo!;
  }

  @override
  void initState() {
    super.initState();
    _favoritesBox = Hive.box<Map>(favoritesBoxName);
    _queueService = ReviewQueueService();
    _repo();
    _startTime = DateTime.now();
    FlashcardRepository.loadAll().then((cards) {
      if (mounted) setState(() => _allWords = cards);
    });
    _loadQuestion();
  }

  List<Flashcard> _getAllWords() {
    return _allWords ?? widget.quizSessionWords;
  }

  void _loadFavoriteStatus(String wordId) {
    if (_favoriteStatusMap.containsKey(wordId)) return;
    final status = {
      for (final c in StarColor.values) c: false,
    };
    final raw = _favoritesBox.get(wordId);
    if (raw != null) {
      final stored = raw.map((k, v) => MapEntry(k.toString(), v as bool));
      status[StarColor.red] = stored['red'] ?? false;
      status[StarColor.yellow] = stored['yellow'] ?? false;
      status[StarColor.blue] = stored['blue'] ?? false;
    }
    _favoriteStatusMap[wordId] = status;
  }

  Future<void> _toggleFavorite(String wordId, StarColor colorKey) async {
    _loadFavoriteStatus(wordId);
    final current = Map<StarColor, bool>.from(_favoriteStatusMap[wordId]!);
    current[colorKey] = !(current[colorKey] ?? false);
    await _favoritesBox
        .put(wordId, {for (final e in current.entries) e.key.name: e.value});
    if (!mounted) return;
    setState(() {
      _favoriteStatusMap[wordId] = current;
    });
  }

  void _generateChoices() {
    List<Flashcard> all = _getAllWords();
    List<Flashcard> pool = List<Flashcard>.from(all)
      ..removeWhere((e) => e.id == _currentFlashcard.id);
    pool.shuffle(Random());
    List<Flashcard> incorrect = pool.take(3).toList();
    _choices = [_currentFlashcard, ...incorrect];
    _choices.shuffle(Random());
  }

  void _loadQuestion() {
    _currentFlashcard = widget.quizSessionWords[_currentIndex];
    _generateChoices();
    for (var card in _choices) {
      _loadFavoriteStatus(card.id);
    }
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

  void _onSelect(String term) {
    if (_answered) return;
    _selectedTerm = term;
    bool correct = term == _currentFlashcard.term;
    if (correct) _score++;
    _answerResults.add(correct);
    _recordAnswer(correct);
    setState(() {
      _answered = true;
    });
  }

  void _nextQuestion() {
    if (_currentIndex + 1 >= widget.totalSessionQuestions) {
      _goToResults();
      return;
    }
    setState(() {
      _currentIndex++;
    });
    _loadQuestion();
  }

  void _goToResults() {
    final answeredWords =
        widget.quizSessionWords.take(_answerResults.length).toList();
    final elapsed = DateTime.now().difference(_startTime).inSeconds;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          words: answeredWords,
          answerResults: _answerResults,
          score: _score,
          durationSeconds: elapsed,
        ),
      ),
    );
  }

  Future<void> _confirmQuit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('クイズを終了しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('終了'),
            ),
          ],
        );
      },
    );
    if (result == true) {
      _goToResults();
    }
  }

  Widget _buildStarIcon(String wordId, StarColor colorKey, Color color) {
    final status = _favoriteStatusMap[wordId] ??
        {for (final c in StarColor.values) c: false};
    bool isFavorite = status[colorKey] ?? false;
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.star : Icons.star_border,
        color: isFavorite ? color : Theme.of(context).colorScheme.outline,
        size: 24,
      ),
      onPressed: () => _toggleFavorite(wordId, colorKey),
      tooltip: '${colorKey.label}星',
    );
  }

  Widget _buildChoiceButton(Flashcard card) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _onSelect(card.term),
        child: Text(card.term),
      ),
    );
  }

  Widget _buildAnswerView() {
    final bool correct = _selectedTerm == _currentFlashcard.term;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Icon(
          correct ? Icons.circle : Icons.close,
          color: correct
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.error,
          size: 64,
        ),
        const SizedBox(height: 16),
        Text(
          correct ? '正解！' : '不正解',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        if (widget.quizSessionType == QuizType.multipleChoice) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStarIcon(_currentFlashcard.id, StarColor.red,
                  Theme.of(context).colorScheme.error),
              _buildStarIcon(_currentFlashcard.id, StarColor.yellow,
                  Theme.of(context).colorScheme.secondary),
              _buildStarIcon(_currentFlashcard.id, StarColor.blue,
                  Theme.of(context).colorScheme.primary),
            ],
          ),
        ] else ...[
          Column(
            children: _choices
                .map(
                  (c) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  c.term,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildStarIcon(c.id, StarColor.red,
                                      Theme.of(context).colorScheme.error),
                                  _buildStarIcon(c.id, StarColor.yellow,
                                      Theme.of(context).colorScheme.secondary),
                                  _buildStarIcon(c.id, StarColor.blue,
                                      Theme.of(context).colorScheme.primary),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(c.description),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _nextQuestion,
          child: const Text('次の問題へ'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('クイズ'),
        actions: [
          TextButton(
            onPressed: _confirmQuit,
            child: const Text('終了'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${widget.totalSessionQuestions}問中 ${_currentIndex + 1}問目'),
            const SizedBox(height: 16),
            Text(
              _currentFlashcard.description,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: !_answered
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _choices
                            .map(
                              (c) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: _buildChoiceButton(c),
                              ),
                            )
                            .toList(),
                      )
                    : _buildAnswerView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
