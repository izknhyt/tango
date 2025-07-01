import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/quiz_stat.dart';

class AggregateStatsNotifier extends StateNotifier<Map<String, int>> {
  AggregateStatsNotifier() : super(const {'questions': 0, 'correct': 0});

  void aggregate(Iterable<QuizStat> entries) {
    int questions = 0;
    int correct = 0;
    for (final m in entries) {
      questions += m.questionCount;
      correct += m.correctCount;
    }
    state = {'questions': questions, 'correct': correct};
  }
}

final aggregateStatsProvider =
    StateNotifierProvider<AggregateStatsNotifier, Map<String, int>>((ref) {
  return AggregateStatsNotifier();
});
