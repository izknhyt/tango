import 'package:hive/hive.dart';

part 'session_log.g.dart';

@HiveType(typeId: 5)
class SessionLog extends HiveObject {
  @HiveField(0)
  final DateTime startTime;
  @HiveField(1)
  final DateTime endTime;
  @HiveField(2)
  final int wordCount;
  @HiveField(3)
  final int correctCount;

  SessionLog({
    required this.startTime,
    required this.endTime,
    required this.wordCount,
    required this.correctCount,
  });

  int get durationSeconds => endTime.difference(startTime).inSeconds;
}
