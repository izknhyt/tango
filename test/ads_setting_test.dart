import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:hive/hive.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:tango/constants.dart';
import 'package:tango/tabs_content/settings_tab_content.dart';
import 'package:tango/ads_personalization_provider.dart';
import 'package:tango/theme_provider.dart';

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

  testWidgets('ads switch persists to hive', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: provider_pkg.ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MaterialApp(home: SettingsTabContent()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final finder = find.widgetWithText(SwitchListTile, '広告パーソナライズ');
    expect(tester.widget<SwitchListTile>(finder).value, isFalse);

    await tester.tap(finder);
    await tester.pumpAndSettle();

    expect(tester.widget<SwitchListTile>(finder).value, isTrue);
    expect(box.get(AdsPersonalizationNotifier.key), isTrue);
  });
}
