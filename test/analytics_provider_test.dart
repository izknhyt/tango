import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:tango/analytics_provider.dart';
import 'package:tango/constants.dart';

void main() {
  late Directory dir;
  late Box box;
  late AnalyticsNotifier notifier;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    box = await Hive.openBox(settingsBoxName);
    notifier = AnalyticsNotifier(box);
    await notifier.load();
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk(settingsBoxName);
    await dir.delete(recursive: true);
  });

  test('initial value false', () {
    expect(notifier.state, isFalse);
  });

  test('toggle updates state and box', () async {
    await notifier.setEnabled(true);
    expect(notifier.state, isTrue);
    expect(box.get(AnalyticsNotifier.key), isTrue);
  });
}
