import 'package:hive/hive.dart';

part 'quiz_stat.g.dart';

@HiveType(typeId: 4)
class QuizStat extends HiveObject {
  @HiveField(0)
  final DateTime timestamp;
  @HiveField(1)
  final int questionCount;
  @HiveField(2)
  final int correctCount;
  @HiveField(3)
  final int durationSeconds;
  @HiveField(4)
  final List<String> wordIds;
  @HiveField(5)
  final List<bool> results;

  QuizStat({
    required this.timestamp,
    required this.questionCount,
    required this.correctCount,
    required this.durationSeconds,
    required this.wordIds,
    required this.results,
  });
}
