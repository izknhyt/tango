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
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MaterialApp(
        home: WordbookScreen(
      flashcards: cards,
      prefsProvider: () async => prefs,
    )));
    await tester.pumpAndSettle();
    expect(find.text('(2 / 2)'), findsOneWidget);
  });

  testWidgets('saves bookmark on page change', (tester) async {
    SharedPreferences.setMockInitialValues({'bookmark_pageIndex': 0});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MaterialApp(
        home: WordbookScreen(
      flashcards: cards,
      prefsProvider: () async => prefs,
    )));
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(prefs.getInt('bookmark_pageIndex'), 1);
  });

  testWidgets('search selects page and saves bookmark', (tester) async {
    SharedPreferences.setMockInitialValues({'bookmark_pageIndex': 0});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MaterialApp(
        home: WordbookScreen(
      flashcards: cards,
      prefsProvider: () async => prefs,
    )));

    // Open search bottom sheet
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // Enter query and select result
    await tester.enterText(find.byType(TextField), 'b');
    await tester.pumpAndSettle();
    await tester.tap(find.text('b').last);
    await tester.pumpAndSettle();

    // PageView moved to selected index
    expect(find.text('(2 / 2)'), findsOneWidget);

    // Bookmark saved
    expect(prefs.getInt('bookmark_pageIndex'), 1);
  });

  testWidgets('shows nav arrows on wide screen', (tester) async {
    SharedPreferences.setMockInitialValues({'bookmark_pageIndex': 0});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(size: Size(800, 600)),
      child: MaterialApp(
        home: WordbookScreen(
          flashcards: cards,
          prefsProvider: () async => prefs,
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('edge taps navigate pages', (tester) async {
    SharedPreferences.setMockInitialValues({'bookmark_pageIndex': 0});
    final prefs = await SharedPreferences.getInstance();
    final key = GlobalKey<WordbookScreenState>();
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(size: Size(320, 600)),
      child: MaterialApp(
        home: WordbookScreen(
          key: key,
          flashcards: cards,
          prefsProvider: () async => prefs,
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(key.currentState!.currentIndex, 0);
    await tester.tapAt(const Offset(310, 300));
    await tester.pumpAndSettle();
    expect(key.currentState!.currentIndex, 1);
    await tester.tapAt(const Offset(10, 300));
    await tester.pumpAndSettle();
    expect(key.currentState!.currentIndex, 0);
  });

  testWidgets('center tap toggles slider and slider changes page', (tester) async {
    SharedPreferences.setMockInitialValues({'bookmark_pageIndex': 0});
    final prefs = await SharedPreferences.getInstance();
    final key = GlobalKey<WordbookScreenState>();
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(size: Size(320, 600)),
      child: MaterialApp(
        home: WordbookScreen(
          key: key,
          flashcards: cards,
          prefsProvider: () async => prefs,
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(Slider), findsNothing);
    await tester.tapAt(const Offset(160, 300));
    await tester.pumpAndSettle();
    expect(find.byType(Slider), findsOneWidget);
    await tester.drag(find.byType(Slider), const Offset(100, 0));
    await tester.pumpAndSettle();
    expect(key.currentState!.currentIndex, 1);
  });
}
