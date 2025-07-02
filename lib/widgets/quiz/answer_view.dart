import 'package:flutter/material.dart';

import '../../flashcard_model.dart';
import '../../quiz_setup_screen.dart';
import '../../star_color.dart';

class AnswerView extends StatelessWidget {
  final bool correct;
  final QuizType quizType;
  final Flashcard current;
  final List<Flashcard> choices;
  final Widget Function(String wordId, StarColor colorKey, Color color)
      buildStarIcon;
  final VoidCallback onNext;

  const AnswerView({
    super.key,
    required this.correct,
    required this.quizType,
    required this.current,
    required this.choices,
    required this.buildStarIcon,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
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
        if (quizType == QuizType.multipleChoice) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildStarIcon(current.id, StarColor.red,
                  Theme.of(context).colorScheme.error),
              buildStarIcon(current.id, StarColor.yellow,
                  Theme.of(context).colorScheme.secondary),
              buildStarIcon(current.id, StarColor.blue,
                  Theme.of(context).colorScheme.primary),
            ],
          ),
        ] else ...[
          Column(
            children: choices
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
                                  buildStarIcon(c.id, StarColor.red,
                                      Theme.of(context).colorScheme.error),
                                  buildStarIcon(c.id, StarColor.yellow,
                                      Theme.of(context).colorScheme.secondary),
                                  buildStarIcon(c.id, StarColor.blue,
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
          onPressed: onNext,
          child: const Text('次の問題へ'),
        ),
      ],
    );
  }
}
