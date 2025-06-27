// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_theme_mode.dart';

class SavedThemeModeAdapter extends TypeAdapter<SavedThemeMode> {
  @override
  final int typeId = 7;

  @override
  SavedThemeMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 1:
        return SavedThemeMode.light;
      case 2:
        return SavedThemeMode.dark;
      case 0:
      default:
        return SavedThemeMode.system;
    }
  }

  @override
  void write(BinaryWriter writer, SavedThemeMode obj) {
    switch (obj) {
      case SavedThemeMode.system:
        writer.writeByte(0);
        break;
      case SavedThemeMode.light:
        writer.writeByte(1);
        break;
      case SavedThemeMode.dark:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedThemeModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
