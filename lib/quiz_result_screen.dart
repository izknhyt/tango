import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flashcard_model.dart';
import 'review_service.dart';
import 'tag_stats.dart';
import 'constants.dart';
import 'models/flashcard_state.dart';
import 'models/quiz_stat.dart';
import 'wordbook_screen.dart';

class QuizResultScreen extends StatefulWidget {
  final List<Flashcard> words;
  final List<bool> answerResults;
  final int score;
  final int durationSeconds;

  const QuizResultScreen({
    Key? key,
    required this.words,
    required this.answerResults,
    required this.score,
    required this.durationSeconds,
  }) : super(key: key);

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  late Box<QuizStat> _statsBox;
  late Box<FlashcardState> _stateBox;
  bool _showDescriptions = true;

  @override
  void initState() {
    super.initState();
    _statsBox = Hive.box<QuizStat>(quizStatsBoxName);
    _stateBox = Hive.box<FlashcardState>(flashcardStateBoxName);
    _addStatsEntry().then((_) {
      if (mounted) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _showSummaryDialog());
      }
    });
  }

  Future<void> _addStatsEntry() async {
    final entry = QuizStat(
      timestamp: DateTime.now(),
      questionCount: widget.words.length,
      correctCount: widget.score,
      durationSeconds: widget.durationSeconds,
      wordIds: widget.words.map((w) => w.id).toList(),
      results: widget.answerResults,
    );
    await _statsBox.add(entry);

    for (int i = 0; i < widget.words.length; i++) {
      final card = widget.words[i];
      final bool correct =
          i < widget.answerResults.length && widget.answerResults[i];
      final current = _stateBox.get(card.id) ?? FlashcardState();
      final statsMap = Map<String, TagStats>.from(current.tagStats);
      for (final tag in card.tags ?? <String>[]) {
        final TagStats stats = statsMap[tag] ?? TagStats();
        stats.totalAttempts++;
        if (!correct) stats.totalWrong++;
        statsMap[tag] = stats;
      }
      await _stateBox.put(
          card.id,
          current.copyWith(
            tagStats: statsMap,
            lastReviewed: card.lastReviewed,
            nextDue: card.nextDue,
            wrongCount: card.wrongCount,
            correctCount: card.correctCount,
          ));
    }
  }

  // Shows summary dialog after quiz completion

  Future<void> _showSummaryDialog() async {
    final accuracy =
        widget.words.isEmpty ? 0 : widget.score / widget.words.length * 100;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('結果'),
          content: Text(
            '正答率 ${accuracy.toStringAsFixed(1)}%'
            ' (${widget.score}/${widget.words.length})',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WordbookScreen(
                      flashcards: widget.words,
                      prefsProvider: SharedPreferences.getInstance,
                    ),
                  ),
                );
              },
              child: const Text('単語帳で確認'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('結果')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'スコア: ${widget.score} / ${widget.words.length}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            title: const Text('単語概要を表示'),
            value: _showDescriptions,
            onChanged: (val) => setState(() => _showDescriptions = val),
          ),
          const SizedBox(height: 16),
          ...List.generate(widget.words.length, (index) {
            final card = widget.words[index];
            final bool correct = index < widget.answerResults.length &&
                widget.answerResults[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Q${index + 1}: ',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        Expanded(
                            child: Text(card.term,
                                style: Theme.of(context).textTheme.bodyLarge)),
                        Icon(
                          correct ? Icons.circle : Icons.close,
                          color: correct
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.error,
                          size: 20,
                        ),
                      ],
                    ),
                    if (_showDescriptions) ...[
                      const SizedBox(height: 8),
                      Text(card.description),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
