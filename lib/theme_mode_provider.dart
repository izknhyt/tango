import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'constants.dart';
import 'models/saved_theme_mode.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._box) : super(ThemeMode.system);

  final Box<SavedThemeMode> _box;
  static const _key = 'theme_mode';

  Future<void> load() async {
    final saved = _box.get(_key);
    switch (saved) {
      case SavedThemeMode.light:
        state = ThemeMode.light;
        break;
      case SavedThemeMode.dark:
        state = ThemeMode.dark;
        break;
      case SavedThemeMode.system:
      case null:
        state = ThemeMode.system;
        break;
    }
  }

  Future<void> toggle(ThemeMode mode) async {
    state = mode;
    SavedThemeMode saved;
    switch (mode) {
      case ThemeMode.light:
        saved = SavedThemeMode.light;
        break;
      case ThemeMode.dark:
        saved = SavedThemeMode.dark;
        break;
      case ThemeMode.system:
      default:
        saved = SavedThemeMode.system;
        break;
    }
    await _box.put(_key, saved);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final box = Hive.box<SavedThemeMode>(settingsBoxName);
  final notifier = ThemeModeNotifier(box);
  notifier.load();
  return notifier;
});
