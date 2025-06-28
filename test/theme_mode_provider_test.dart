import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:tango/theme_mode_provider.dart';
import 'package:tango/models/saved_theme_mode.dart';
import 'package:tango/constants.dart';

void main() {
  late Directory dir;
  late Box box;
  late ThemeModeNotifier notifier;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(SavedThemeModeAdapter().typeId)) {
      Hive.registerAdapter(SavedThemeModeAdapter());
    }
    box = await Hive.openBox(settingsBoxName);
    notifier = ThemeModeNotifier(box);
    await notifier.load();
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk(settingsBoxName);
    await dir.delete(recursive: true);
  });

  test('initial value system', () {
    expect(notifier.state, ThemeMode.system);
  });

  test('toggle updates state and box', () async {
    await notifier.toggle(ThemeMode.dark);
    expect(notifier.state, ThemeMode.dark);
    expect(box.get('mode'), SavedThemeMode.dark);
  });
}
