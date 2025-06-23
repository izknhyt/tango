// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word.dart';

class WordAdapter extends TypeAdapter<Word> {
  @override
  final int typeId = 2;

  @override
  Word read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Word(
      id: fields[0] as String,
      term: fields[1] as String,
      reading: fields[2] as String,
      description: fields[3] as String,
      relatedIds: (fields[4] as List?)?.cast<String>(),
      tags: (fields[5] as List?)?.cast<String>(),
      examExample: fields[6] as String?,
      examPoint: fields[7] as String?,
      practicalTip: fields[8] as String?,
      categoryLarge: fields[9] as String,
      categoryMedium: fields[10] as String,
      categorySmall: fields[11] as String,
      categoryItem: fields[12] as String,
      importance: fields[13] as double,
      english: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Word obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.term)
      ..writeByte(2)
      ..write(obj.reading)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.relatedIds)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.examExample)
      ..writeByte(7)
      ..write(obj.examPoint)
      ..writeByte(8)
      ..write(obj.practicalTip)
      ..writeByte(9)
      ..write(obj.categoryLarge)
      ..writeByte(10)
      ..write(obj.categoryMedium)
      ..writeByte(11)
      ..write(obj.categorySmall)
      ..writeByte(12)
      ..write(obj.categoryItem)
      ..writeByte(13)
      ..write(obj.importance)
      ..writeByte(14)
      ..write(obj.english);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
