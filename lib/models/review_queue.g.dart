// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_queue.dart';

class ReviewQueueAdapter extends TypeAdapter<ReviewQueue> {
  @override
  final int typeId = 6;

  @override
  ReviewQueue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReviewQueue(
      wordIds: (fields[0] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ReviewQueue obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.wordIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewQueueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
