// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_stat.dart';

class LearningStatAdapter extends TypeAdapter<LearningStat> {
  @override
  final int typeId = 3;

  @override
  LearningStat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LearningStat(
      wordId: fields[0] as String,
      lastReviewed: fields[1] as DateTime?,
      wrongCount: fields[2] as int,
      viewed: fields[3] as int,
      correctCount: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LearningStat obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.wordId)
      ..writeByte(1)
      ..write(obj.lastReviewed)
      ..writeByte(2)
      ..write(obj.wrongCount)
      ..writeByte(3)
      ..write(obj.viewed)
      ..writeByte(4)
      ..write(obj.correctCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningStatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
