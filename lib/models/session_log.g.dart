// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_log.dart';

class SessionLogAdapter extends TypeAdapter<SessionLog> {
  @override
  final int typeId = 5;

  @override
  SessionLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionLog(
      startTime: fields[0] as DateTime,
      endTime: fields[1] as DateTime,
      wordCount: fields[2] as int,
      correctCount: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SessionLog obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.startTime)
      ..writeByte(1)
      ..write(obj.endTime)
      ..writeByte(2)
      ..write(obj.wordCount)
      ..writeByte(3)
      ..write(obj.correctCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
