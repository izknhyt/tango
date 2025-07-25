
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:tango/theme_mode_provider.dart';
import 'package:tango/models/saved_theme_mode.dart';
import 'package:tango/constants.dart';
import 'test_harness.dart' hide setUpAll;

void main() {
  late Box<SavedThemeMode> box;
  late ThemeModeNotifier notifier;

  setUpAll(() async {
    box = await openTypedBox<SavedThemeMode>(settingsBoxName);
    notifier = ThemeModeNotifier(box);
    await notifier.load();
  });

  tearDown(() async {
    await box.clear();
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
