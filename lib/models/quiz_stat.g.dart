// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_stat.dart';

class QuizStatAdapter extends TypeAdapter<QuizStat> {
  @override
  final int typeId = 4;

  @override
  QuizStat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizStat(
      timestamp: fields[0] as DateTime,
      questionCount: fields[1] as int,
      correctCount: fields[2] as int,
      durationSeconds: fields[3] as int,
      wordIds: (fields[4] as List).cast<String>(),
      results: (fields[5] as List).cast<bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, QuizStat obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.questionCount)
      ..writeByte(2)
      ..write(obj.correctCount)
      ..writeByte(3)
      ..write(obj.durationSeconds)
      ..writeByte(4)
      ..write(obj.wordIds)
      ..writeByte(5)
      ..write(obj.results);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizStatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
