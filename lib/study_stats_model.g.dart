// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_stats_model.dart';

class StudyStatsAdapter extends TypeAdapter<StudyStats> {
  @override
  final int typeId = 2;

  @override
  StudyStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudyStats(
      date: fields[0] as DateTime,
      wordsViewed: fields[1] as int,
      quizzesTaken: fields[2] as int,
      correctAnswers: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, StudyStats obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.wordsViewed)
      ..writeByte(2)
      ..write(obj.quizzesTaken)
      ..writeByte(3)
      ..write(obj.correctAnswers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
