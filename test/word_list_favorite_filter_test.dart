import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:tango/constants.dart';
import 'package:tango/flashcard_model.dart';
import 'package:tango/tabs_content/word_list_tab_content.dart';
import 'package:tango/word_list_query.dart';

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
      lastReviewed: null,
      nextDue: null,
      wrongCount: 0,
      correctCount: 0,
    );

void main() {
  late Directory dir;
  late Box<Map> favBox;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    favBox = await Hive.openBox<Map>(favoritesBoxName);
  });

  tearDown(() async {
    await favBox.close();
    await Hive.deleteBoxFromDisk(favoritesBoxName);
    await dir.delete(recursive: true);
  });

  testWidgets('favorite filter shows only favorited words', (tester) async {
    final card1 = _card('1');
    final card2 = _card('2');
    await favBox.put('2', {'red': true});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wordListForModeProvider.overrideWith((ref) => [card1, card2]),
          currentQueryProvider.overrideWith(
            (ref) => const WordListQuery(filters: {WordFilter.favorite}),
          ),
        ],
        child: MaterialApp(
          home: WordListTabContent(onWordTap: (_, __) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsOneWidget);
  });
}
