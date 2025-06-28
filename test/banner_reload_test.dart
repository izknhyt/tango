import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tango/constants.dart';
import 'package:tango/wordbook_screen.dart';
import 'package:tango/flashcard_model.dart';
import 'package:tango/ads_personalization_provider.dart';

Flashcard _card(String id) => Flashcard(
      id: id,
      term: id,
      reading: id,
      description: 'd',
      categoryLarge: 'A',
      categoryMedium: 'B',
      categorySmall: 'C',
      categoryItem: 'D',
      importance: 1,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: ['TEST_DEVICE']));
  MobileAds.instance.initialize();

  late Directory dir;
  late Box box;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    box = await Hive.openBox(settingsBoxName);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk(settingsBoxName);
    await dir.delete(recursive: true);
  });

  testWidgets('banner reloads after toggle', (tester) async {
    final cards = [_card('1')];
    final container = ProviderContainer();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: WordbookScreen(
            flashcards: cards,
            prefsProvider: SharedPreferences.getInstance,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final firstWidget = tester.widget<AdWidget>(find.byType(AdWidget));

    await container.read(adsPersonalizationProvider.notifier).toggle();
    await tester.pumpAndSettle();

    final secondWidget = tester.widget<AdWidget>(find.byType(AdWidget));
    expect(identical(firstWidget.ad, secondWidget.ad), isFalse);
  });
}
