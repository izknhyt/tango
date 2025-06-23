import 'package:hive/hive.dart';

part 'learning_stat.g.dart';

/// Review statistics persisted per word.
@HiveType(typeId: 3)
class LearningStat extends HiveObject {
  @HiveField(0)
  final String wordId;
  @HiveField(1)
  DateTime? lastReviewed;
  @HiveField(2)
  int wrongCount;
  @HiveField(3)
  int viewed;

  LearningStat({
    required this.wordId,
    this.lastReviewed,
    this.wrongCount = 0,
    this.viewed = 0,
  });

  factory LearningStat.fromMap(Map<dynamic, dynamic> map) {
    return LearningStat(
      wordId: map['wordId'] as String,
      lastReviewed: map['lastReviewed'] as DateTime?,
      wrongCount: (map['wrongCount'] as int?) ?? 0,
      viewed: (map['viewed'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'wordId': wordId,
        'lastReviewed': lastReviewed,
        'wrongCount': wrongCount,
        'viewed': viewed,
      };
}
