import 'package:hive/hive.dart';

part 'saved_theme_mode.g.dart';

@HiveType(typeId: 7)
enum SavedThemeMode {
  @HiveField(0)
  system,
  @HiveField(1)
  light,
  @HiveField(2)
  dark,
}
