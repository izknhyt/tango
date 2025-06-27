import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'constants.dart';
import 'models/saved_theme_mode.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._box) : super(ThemeMode.system);

  final Box<SavedThemeMode> _box;

  Future<void> load() async {
    final saved = _box.get('mode');
    state = _toThemeMode(saved ?? SavedThemeMode.system);
  }

  Future<void> toggle(ThemeMode mode) async {
    state = mode;
    await _box.put('mode', _fromThemeMode(mode));
  }

  ThemeMode _toThemeMode(SavedThemeMode saved) {
    switch (saved) {
      case SavedThemeMode.light:
        return ThemeMode.light;
      case SavedThemeMode.dark:
        return ThemeMode.dark;
      case SavedThemeMode.system:
      default:
        return ThemeMode.system;
    }
  }

  SavedThemeMode _fromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return SavedThemeMode.light;
      case ThemeMode.dark:
        return SavedThemeMode.dark;
      case ThemeMode.system:
      default:
        return SavedThemeMode.system;
    }
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final box = Hive.box<SavedThemeMode>(settingsBoxName);
  final notifier = ThemeModeNotifier(box);
  notifier.load();
  return notifier;
});
