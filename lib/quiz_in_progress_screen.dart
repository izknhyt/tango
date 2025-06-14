import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'flashcard_model.dart';
import 'quiz_setup_screen.dart';
import 'quiz_result_screen.dart';

const String favoritesBoxName = 'favorites_box_v2';

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
  int _currentIndex = 0;
  int _score = 0;
  List<bool> _answerResults = [];

  late Flashcard _currentFlashcard;
  List<Flashcard> _choices = [];
  bool _answered = false;
  String? _selectedTerm;

  final Map<String, Map<String, bool>> _favoriteStatusMap = {};
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _favoritesBox = Hive.box<Map>(favoritesBoxName);
    _startTime = DateTime.now();
    _loadQuestion();
  }

  List<Flashcard> _getAllWords() {
    // TODO: replace with real data source containing all flashcards
    return widget.quizSessionWords;
  }

  void _loadFavoriteStatus(String wordId) {
    if (_favoriteStatusMap.containsKey(wordId)) return;
    Map<String, bool> status = {
      'red': false,
      'yellow': false,
      'blue': false,
    };
    final raw = _favoritesBox.get(wordId);
    if (raw != null) {
      final stored = raw.map((k, v) => MapEntry(k.toString(), v as bool));
      status['red'] = stored['red'] ?? false;
      status['yellow'] = stored['yellow'] ?? false;
      status['blue'] = stored['blue'] ?? false;
    }
    _favoriteStatusMap[wordId] = status;
  }

  Future<void> _toggleFavorite(String wordId, String colorKey) async {
    _loadFavoriteStatus(wordId);
    final current = Map<String, bool>.from(_favoriteStatusMap[wordId]!);
    current[colorKey] = !(current[colorKey] ?? false);
    await _favoritesBox.put(wordId, Map<String, dynamic>.from(current));
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

  void _onSelect(String term) {
    if (_answered) return;
    _selectedTerm = term;
    bool correct = term == _currentFlashcard.term;
    if (correct) _score++;
    _answerResults.add(correct);
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
    if (_answerResults.length < widget.totalSessionQuestions) {
      _answerResults.addAll(
        List.filled(
            widget.totalSessionQuestions - _answerResults.length, false),
      );
    }
    final elapsed = DateTime.now().difference(_startTime).inSeconds;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          words: widget.quizSessionWords,
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

  Widget _buildStarIcon(String wordId, String colorKey, Color color) {
    final status = _favoriteStatusMap[wordId] ?? {
      'red': false,
      'yellow': false,
      'blue': false,
    };
    bool isFavorite = status[colorKey] ?? false;
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.star : Icons.star_border,
        color: isFavorite ? color : Colors.grey[400],
        size: 24,
      ),
      onPressed: () => _toggleFavorite(wordId, colorKey),
      tooltip: colorKey == 'red'
          ? '赤星'
          : colorKey == 'yellow'
              ? '黄星'
              : '青星',
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
          color: correct ? Colors.green : Colors.red,
          size: 64,
        ),
        const SizedBox(height: 16),
        Text(
          correct ? '正解！' : '不正解',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        if (widget.quizSessionType == QuizType.multipleChoice) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStarIcon(_currentFlashcard.id, 'red', Colors.redAccent),
              _buildStarIcon(
                  _currentFlashcard.id, 'yellow', Colors.orangeAccent),
              _buildStarIcon(_currentFlashcard.id, 'blue', Colors.blueAccent),
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
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildStarIcon(c.id, 'red', Colors.redAccent),
                                  _buildStarIcon(
                                      c.id, 'yellow', Colors.orangeAccent),
                                  _buildStarIcon(c.id, 'blue', Colors.blueAccent),
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
            child: const Text('終了', style: TextStyle(color: Colors.white)),
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
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            if (!_answered)
              Column(
                children: _choices
                    .map((c) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _buildChoiceButton(c),
                        ))
                    .toList(),
              )
            else
              _buildAnswerView(),
          ],
        ),
      ),
    );
  }
}
