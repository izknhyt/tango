import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tango/flashcard_model.dart';
import 'package:tango/wordbook_screen.dart';

Flashcard _card(int i) => Flashcard(
      id: '$i',
      term: 't$i',
      reading: 't$i',
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
  testWidgets('shows current page indicator in AppBar', (tester) async {
    final cards = List.generate(861, (i) => _card(i + 1));
    SharedPreferences.setMockInitialValues({'bookmark_pageIndex': 77});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MaterialApp(
        home: WordbookScreen(
      flashcards: cards,
      prefsProvider: () async => prefs,
    )));
    await tester.pumpAndSettle();
    expect(find.text('(78 / 861)'), findsOneWidget);
  });
}
