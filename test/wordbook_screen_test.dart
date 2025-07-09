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

  testWidgets('shows nav arrows on narrow screen', (tester) async {
    SharedPreferences.setMockInitialValues({'bookmark_pageIndex': 0});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(size: Size(320, 600)),
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

  testWidgets('tap toggles page controls', (tester) async {
    SharedPreferences.setMockInitialValues({'bookmark_pageIndex': 0});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MaterialApp(
      home: WordbookScreen(
        flashcards: cards,
        prefsProvider: () async => prefs,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(Slider), findsNothing);

    await tester.tap(find.byType(PageView));
    await tester.pumpAndSettle();
    expect(find.byType(Slider), findsOneWidget);

    await tester.tap(find.byType(PageView));
    await tester.pumpAndSettle();
    expect(find.byType(Slider), findsNothing);
  });

  testWidgets('slider changes page and saves bookmark', (tester) async {
    SharedPreferences.setMockInitialValues({'bookmark_pageIndex': 0});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MaterialApp(
      home: WordbookScreen(
        flashcards: cards,
        prefsProvider: () async => prefs,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PageView));
    await tester.pumpAndSettle();

    final sliderFinder = find.byType(Slider);
    final start = tester.getTopLeft(sliderFinder);
    final end = tester.getTopRight(sliderFinder);
    final y = (start.dy + end.dy) / 2;
    await tester.tapAt(Offset(end.dx - 1, y));
    await tester.pumpAndSettle();

    expect(find.text('(2 / 2)'), findsOneWidget);
    expect(prefs.getInt('bookmark_pageIndex'), 1);
  });

  testWidgets('back arrow returns to the previous page', (tester) async {
    SharedPreferences.setMockInitialValues({'bookmark_pageIndex': 0});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MaterialApp(
      home: WordbookScreen(
        flashcards: cards,
        prefsProvider: () async => prefs,
      ),
    ));
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PageView));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('(1 / 2)'), findsOneWidget);
    expect(prefs.getInt('bookmark_pageIndex'), 0);
  });

  testWidgets('forward arrow goes forward after going back', (tester) async {
    SharedPreferences.setMockInitialValues({'bookmark_pageIndex': 0});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MaterialApp(
      home: WordbookScreen(
        flashcards: cards,
        prefsProvider: () async => prefs,
      ),
    ));
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PageView));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();
    expect(find.text('(2 / 2)'), findsOneWidget);
    expect(prefs.getInt('bookmark_pageIndex'), 1);
  });
}
