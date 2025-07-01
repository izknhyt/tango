import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tango/home_stats_provider.dart';
import 'package:tango/models/quiz_stat.dart';

void main() {
  test('aggregates questions and correct count', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(aggregateStatsProvider.notifier);

    final entries = [
      QuizStat(
        timestamp: DateTime.now(),
        questionCount: 5,
        correctCount: 3,
        durationSeconds: 10,
        wordIds: const [],
        results: const [],
      ),
      QuizStat(
        timestamp: DateTime.now(),
        questionCount: 7,
        correctCount: 4,
        durationSeconds: 15,
        wordIds: const [],
        results: const [],
      ),
    ];

    notifier.aggregate(entries);
    final result = container.read(aggregateStatsProvider);
    expect(result['questions'], 12);
    expect(result['correct'], 7);
  });
}
