import 'package:flutter/material.dart';
import 'flashcard_model.dart';

class QuizResultScreen extends StatefulWidget {
  final List<Flashcard> words;
  final List<bool> answerResults;
  final int score;
  final List<List<String>> choices;

  const QuizResultScreen({
    Key? key,
    required this.words,
    required this.answerResults,
    required this.score,
    required this.choices,
  }) : super(key: key);

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  bool _showDescriptions = true;
  bool _showChoices = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('結果')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'スコア: ${widget.score} / ${widget.words.length}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            title: const Text('単語概要を表示'),
            value: _showDescriptions,
            onChanged: (val) => setState(() => _showDescriptions = val),
          ),
          SwitchListTile(
            title: const Text('選択肢を表示'),
            value: _showChoices,
            onChanged: (val) => setState(() => _showChoices = val),
          ),
          const SizedBox(height: 16),
          ...List.generate(widget.words.length, (index) {
            final card = widget.words[index];
            final bool correct = index < widget.answerResults.length &&
                widget.answerResults[index];
            final choices = index < widget.choices.length
                ? widget.choices[index]
                : <String>[];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Q${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Icon(
                          correct ? Icons.circle : Icons.close,
                          color: correct ? Colors.green : Colors.red,
                          size: 20,
                        ),
                      ],
                    ),
                    if (_showDescriptions) ...[
                      const SizedBox(height: 8),
                      Text(card.description),
                    ],
                    const SizedBox(height: 8),
                    Text('正解: ${card.term}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    if (_showChoices && choices.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...choices.map((c) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              c,
                              style: TextStyle(
                                color:
                                    c == card.term ? Colors.green : Colors.black,
                              ),
                            ),
                          )),
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
