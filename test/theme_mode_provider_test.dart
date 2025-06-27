import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:tango/constants.dart';
import 'package:tango/models/saved_theme_mode.dart';
import 'package:tango/theme_mode_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  late Directory dir;
  late Box<SavedThemeMode> box;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    Hive.registerAdapter(SavedThemeModeAdapter());
    box = await Hive.openBox<SavedThemeMode>(settingsBoxName);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk(settingsBoxName);
    await dir.delete(recursive: true);
  });

  test('initial state is system', () async {
    final container = ProviderContainer(overrides: [
      themeModeProvider.overrideWithProvider(
        StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
          final notifier = ThemeModeNotifier(box);
          notifier.load();
          return notifier;
        }),
      ),
    ]);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(themeModeProvider), ThemeMode.system);
  });

  test('toggle updates state and hive', () async {
    final notifier = ThemeModeNotifier(box);
    await notifier.load();
    await notifier.toggle(ThemeMode.dark);
    expect(notifier.state, ThemeMode.dark);
    expect(box.get('theme_mode'), SavedThemeMode.dark);
  });
}
