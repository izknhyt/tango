import 'package:hive/hive.dart';

part 'study_stats_model.g.dart';

@HiveType(typeId: 2)
class StudyStats extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  int wordsViewed;

  @HiveField(2)
  int quizzesTaken;

  @HiveField(3)
  int correctAnswers;

  StudyStats({
    required this.date,
    this.wordsViewed = 0,
    this.quizzesTaken = 0,
    this.correctAnswers = 0,
  });

  @override
  String toString() {
    return 'StudyStats(date: $date, wordsViewed: $wordsViewed, quizzesTaken: $quizzesTaken, correctAnswers: $correctAnswers)';
  }
}

const String studyStatsBoxName = 'study_stats_box_v1';
