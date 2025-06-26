import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tango/flashcard_model.dart';
import 'package:tango/wordbook_screen.dart';

Flashcard _card(String id, String term) => Flashcard(
      id: id,
      term: term,
      reading: term,
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
  final cards = [_card('1', 'a'), _card('2', 'b')];

  testWidgets('restores bookmark page', (tester) async {
    SharedPreferences.setMockInitialValues({'bookmark_pageIndex': 1});
    await tester.pumpWidget(MaterialApp(home: WordbookScreen(flashcards: cards)));
    await tester.pumpAndSettle();
    expect(find.text('現在 2 / 全 2'), findsOneWidget);
  });

  testWidgets('saves bookmark on page change', (tester) async {
    SharedPreferences.setMockInitialValues({'bookmark_pageIndex': 0});
    await tester.pumpWidget(MaterialApp(home: WordbookScreen(flashcards: cards)));
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('bookmark_pageIndex'), 1);
  });

  testWidgets('search selects page and saves bookmark', (tester) async {
    SharedPreferences.setMockInitialValues({'bookmark_pageIndex': 0});
    await tester.pumpWidget(MaterialApp(home: WordbookScreen(flashcards: cards)));

    // Open search bottom sheet
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // Enter query and select result
    await tester.enterText(find.byType(TextField), 'b');
    await tester.pumpAndSettle();
    await tester.tap(find.text('b').last);
    await tester.pumpAndSettle();

    // PageView moved to selected index
    expect(find.text('現在 2 / 全 2'), findsOneWidget);

    // Bookmark saved
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('bookmark_pageIndex'), 1);
  });
}
