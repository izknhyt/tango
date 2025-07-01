import 'package:hive/hive.dart';
import '../tag_stats.dart';

class FlashcardState {
  final DateTime? lastReviewed;
  final DateTime? nextDue;
  final int wrongCount;
  final int correctCount;
  final Map<String, TagStats> tagStats;

  FlashcardState({
    this.lastReviewed,
    this.nextDue,
    this.wrongCount = 0,
    this.correctCount = 0,
    Map<String, TagStats>? tagStats,
  }) : tagStats = tagStats ?? {};

  FlashcardState copyWith({
    DateTime? lastReviewed,
    DateTime? nextDue,
    int? wrongCount,
    int? correctCount,
    Map<String, TagStats>? tagStats,
  }) {
    return FlashcardState(
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextDue: nextDue ?? this.nextDue,
      wrongCount: wrongCount ?? this.wrongCount,
      correctCount: correctCount ?? this.correctCount,
      tagStats: tagStats ?? Map<String, TagStats>.from(this.tagStats),
    );
  }
}

class FlashcardStateAdapter extends TypeAdapter<FlashcardState> {
  @override
  final int typeId = 8;

  @override
  FlashcardState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FlashcardState(
      lastReviewed: fields[0] as DateTime?,
      nextDue: fields[1] as DateTime?,
      wrongCount: fields[2] as int,
      correctCount: fields[3] as int,
      tagStats: (fields[4] as Map?)?.map((k, v) =>
              MapEntry(k as String, TagStats.fromMap(v as Map))) ??
          {},
    );
  }

  @override
  void write(BinaryWriter writer, FlashcardState obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.lastReviewed)
      ..writeByte(1)
      ..write(obj.nextDue)
      ..writeByte(2)
      ..write(obj.wrongCount)
      ..writeByte(3)
      ..write(obj.correctCount)
      ..writeByte(4)
      ..write(obj.tagStats.map((k, v) => MapEntry(k, v.toMap())));
  }
}
