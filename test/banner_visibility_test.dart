import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:tango/constants.dart';
import 'package:tango/quiz_result_screen.dart';
import 'package:tango/flashcard_model.dart';
import 'package:tango/models/quiz_stat.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  late Directory dir;
  late Box<QuizStat> statsBox;
  late Box<Map> stateBox;

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

  setUp(() async {
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    Hive.registerAdapter(QuizStatAdapter());
    statsBox = await Hive.openBox<QuizStat>(quizStatsBoxName);
    stateBox = await Hive.openBox<Map>(flashcardStateBoxName);
  });

  tearDown(() async {
    await statsBox.close();
    await stateBox.close();
    await Hive.deleteBoxFromDisk(quizStatsBoxName);
    await Hive.deleteBoxFromDisk(flashcardStateBoxName);
    await dir.delete(recursive: true);
  });

  testWidgets('banner widget appears in result dialog', (tester) async {
    final card = _card('1');
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: QuizResultScreen(
            words: [card],
            answerResults: [true],
            score: 1,
            durationSeconds: 1,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(AdWidget), findsOneWidget);
  });
}
