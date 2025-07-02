import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'controllers/quiz_controller.dart';
import 'flashcard_model.dart';
import 'flashcard_repository_provider.dart';
import 'quiz_setup_screen.dart';
import 'quiz_result_screen.dart';
import 'widgets/quiz/choice_button.dart';
import 'widgets/quiz/answer_view.dart';
import 'star_color.dart';
import 'constants.dart';

class QuizInProgressScreen extends ConsumerStatefulWidget {
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
  ConsumerState<QuizInProgressScreen> createState() => _QuizInProgressScreenState();
}

class _QuizInProgressScreenState extends ConsumerState<QuizInProgressScreen> {
  late Box<Map> _favoritesBox;
  late QuizController _controller;
  final Map<String, Map<StarColor, bool>> _favoriteStatusMap = {};


  @override
  void initState() {
    super.initState();
    _favoritesBox = Hive.box<Map>(favoritesBoxName);
    _controller = QuizController(
      words: widget.quizSessionWords,
      totalQuestions: widget.totalSessionQuestions,
      quizType: widget.quizSessionType,
    )..addListener(() => setState(() {}));
    ref.read(flashcardRepositoryProvider).loadAll().then((cards) {
      if (mounted) _controller.setAllWords(cards);
    });
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

  void _onSelect(String term) {
    _controller.select(term);
  }

  void _nextQuestion() {
    if (_controller.currentIndex + 1 >= widget.totalSessionQuestions) {
      _goToResults();
      return;
    }
    _controller.next();
  }

  void _goToResults() {
    final answeredWords =
        widget.quizSessionWords.take(_controller.answerResults.length).toList();
    final elapsed = DateTime.now().difference(_controller.startTime).inSeconds;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          words: answeredWords,
          answerResults: _controller.answerResults,
          score: _controller.score,
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
    _loadFavoriteStatus(card.id);
    return ChoiceButton(
      card: card,
      onPressed: () => _onSelect(card.term),
    );
  }

  Widget _buildAnswerView() {
    final correct = _controller.selectedTerm == _controller.currentFlashcard.term;
    return AnswerView(
      correct: correct,
      quizType: widget.quizSessionType,
      current: _controller!.currentFlashcard,
      choices: _controller!.choices,
      buildStarIcon: _buildStarIcon,
      onNext: _nextQuestion,
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
            Text('${widget.totalSessionQuestions}問中 ${_controller!.currentIndex + 1}問目'),
            const SizedBox(height: 16),
            Text(
              _controller!.currentFlashcard.description,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: !_controller!.answered
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _controller!.choices
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
