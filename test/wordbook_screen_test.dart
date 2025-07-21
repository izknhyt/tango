import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tango/flashcard_model.dart';
import 'package:hive/hive.dart';
import 'package:tango/models/bookmark.dart';
import 'package:tango/services/bookmark_service.dart';
import 'package:tango/constants.dart';
import 'package:tango/wordbook_screen.dart';
import 'test_harness.dart';

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

Flashcard _cardWithRelated(String id, String term, List<String> related) =>
    Flashcard(
      id: id,
      term: term,
      reading: term,
      description: 'd',
      relatedIds: related,
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
  late Directory hiveTempDir;
  late Box<Bookmark> box;

  setUpAll(() async {
    hiveTempDir = await initHiveForTests();
    if (!Hive.isBoxOpen(bookmarksBoxName)) {
      await Hive.openBox<Bookmark>(bookmarksBoxName);
    }
    box = Hive.box<Bookmark>(bookmarksBoxName);
  });

  tearDown(() async {
    await box.clear();
  });

  tearDownAll(() async {
    await closeHiveForTests(hiveTempDir);
  });
  final cards = [_card('1', 'a'), _card('2', 'b')];

  testWidgets('restores bookmark page', (tester) async {
    SharedPreferences.setMockInitialValues({'bookmark_pageIndex': 1});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MaterialApp(
        home: WordbookScreen(
      flashcards: cards,
      prefsProvider: () async => prefs,
      bookmarkService: BookmarkService(box),
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
      bookmarkService: BookmarkService(box),
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
      bookmarkService: BookmarkService(box),
    )));

    // Open search bottom sheet
    final searchIconFinder = find.byIcon(Icons.search);
    expect(searchIconFinder, findsOneWidget);
    await tester.tap(searchIconFinder);
    await tester.pumpAndSettle();

    // Enter query and select result
    await tester.enterText(find.byType(TextField), 'b');
    await tester.pumpAndSettle();
    final resultFinder = find.text('b').last;
    expect(resultFinder, findsOneWidget);
    await tester.tap(resultFinder);
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
          bookmarkService: BookmarkService(box),
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
          bookmarkService: BookmarkService(box),
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
        bookmarkService: BookmarkService(box),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(Slider), findsNothing);

    final pageViewFinder = find.byType(PageView);
    expect(pageViewFinder, findsOneWidget);
    await tester.tap(pageViewFinder);
    await tester.pumpAndSettle();
    expect(find.byType(Slider), findsOneWidget);

    await tester.tap(pageViewFinder);
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
        bookmarkService: BookmarkService(box),
      ),
    ));
    await tester.pumpAndSettle();

    final pageViewFinder = find.byType(PageView);
    expect(pageViewFinder, findsOneWidget);
    await tester.tap(pageViewFinder);
    await tester.pumpAndSettle();

    final sliderFinder = find.byType(Slider);
    expect(sliderFinder, findsOneWidget);
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
        bookmarkService: BookmarkService(box),
      ),
    ));
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    final pageViewFinder = find.byType(PageView);
    expect(pageViewFinder, findsOneWidget);
    await tester.tap(pageViewFinder);
    await tester.pumpAndSettle();
    final backFinder = find.byIcon(Icons.arrow_back);
    expect(backFinder, findsOneWidget);
    await tester.tap(backFinder);
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
        bookmarkService: BookmarkService(box),
      ),
    ));
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    final pageViewFinder = find.byType(PageView);
    expect(pageViewFinder, findsOneWidget);
    await tester.tap(pageViewFinder);
    await tester.pumpAndSettle();
    final backFinder = find.byIcon(Icons.arrow_back);
    expect(backFinder, findsOneWidget);
    await tester.tap(backFinder);
    await tester.pumpAndSettle();
    final forwardFinder = find.byIcon(Icons.arrow_forward);
    expect(forwardFinder, findsOneWidget);
    await tester.tap(forwardFinder);
    await tester.pumpAndSettle();
    expect(find.text('(2 / 2)'), findsOneWidget);
    expect(prefs.getInt('bookmark_pageIndex'), 1);
  });

  testWidgets('search navigation pushes single history entry', (tester) async {
    SharedPreferences.setMockInitialValues({'bookmark_pageIndex': 0});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MaterialApp(
      home: WordbookScreen(
        flashcards: cards,
        prefsProvider: () async => prefs,
        bookmarkService: BookmarkService(box),
      ),
    ));

    final searchIconFinder2 = find.byIcon(Icons.search);
    expect(searchIconFinder2, findsOneWidget);
    await tester.tap(searchIconFinder2);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'b');
    await tester.pumpAndSettle();
    final resultFinder2 = find.text('b').last;
    expect(resultFinder2, findsOneWidget);
    await tester.tap(resultFinder2);
    await tester.pumpAndSettle();

    final pageViewFinder2 = find.byType(PageView);
    expect(pageViewFinder2, findsOneWidget);
    await tester.tap(pageViewFinder2);
    await tester.pumpAndSettle();
    final backFinder2 = find.byIcon(Icons.arrow_back);
    expect(backFinder2, findsOneWidget);
    await tester.tap(backFinder2);
    await tester.pumpAndSettle();
    expect(find.text('(1 / 2)'), findsOneWidget);

    final forwardFinder2 = find.byIcon(Icons.arrow_forward);
    expect(forwardFinder2, findsOneWidget);
    await tester.tap(forwardFinder2);
    await tester.pumpAndSettle();
    expect(find.text('(2 / 2)'), findsOneWidget);
  });

  testWidgets('related term navigation pushes single history entry',
      (tester) async {
    final relatedCards = [
      _cardWithRelated('1', 'a', ['2']),
      _card('2', 'b'),
    ];
    SharedPreferences.setMockInitialValues({'bookmark_pageIndex': 0});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MaterialApp(
      home: WordbookScreen(
        flashcards: relatedCards,
        prefsProvider: () async => prefs,
        bookmarkService: BookmarkService(box),
      ),
    ));

    // Tap related term button (shows dialog)
    final relatedFinder = find.widgetWithText(TextButton, 'b');
    expect(relatedFinder, findsOneWidget);
    await tester.tap(relatedFinder);
    await tester.pumpAndSettle();
    final dialogFinder = find.byType(AlertDialog);
    expect(dialogFinder, findsOneWidget);
    await tester.tap(dialogFinder);
    await tester.pumpAndSettle();

    final pageViewFinder3 = find.byType(PageView);
    expect(pageViewFinder3, findsOneWidget);
    await tester.tap(pageViewFinder3);
    await tester.pumpAndSettle();
    final backFinder3 = find.byIcon(Icons.arrow_back);
    expect(backFinder3, findsOneWidget);
    await tester.tap(backFinder3);
    await tester.pumpAndSettle();
    expect(find.text('(1 / 2)'), findsOneWidget);

    final forwardFinder3 = find.byIcon(Icons.arrow_forward);
    expect(forwardFinder3, findsOneWidget);
    await tester.tap(forwardFinder3);
    await tester.pumpAndSettle();
    expect(find.text('(2 / 2)'), findsOneWidget);
  });

  testWidgets('bookmark add/remove stored in Hive', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = BookmarkService(box);

    await tester.pumpWidget(MaterialApp(
      home: WordbookScreen(
        flashcards: cards,
        prefsProvider: () async => prefs,
        bookmarkService: service,
      ),
    ));
    await tester.pumpAndSettle();

    final pageViewFinder4 = find.byType(PageView);
    expect(pageViewFinder4, findsOneWidget);
    await tester.tap(pageViewFinder4);
    await tester.pumpAndSettle();
    final addBookmarkFinder = find.byIcon(Icons.bookmark_border);
    expect(addBookmarkFinder, findsOneWidget);
    await tester.tap(addBookmarkFinder);
    await tester.pumpAndSettle();
    expect(box.containsKey(0), isTrue);

    final removeBookmarkFinder = find.byIcon(Icons.bookmark);
    expect(removeBookmarkFinder, findsOneWidget);
    await tester.tap(removeBookmarkFinder);
    await tester.pumpAndSettle();
    expect(box.containsKey(0), isFalse);

  });

  testWidgets('slider shows markers and selecting from list jumps to page',
      (tester) async {
    final service = BookmarkService(box);
    await service.addBookmark(1);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(MaterialApp(
      home: WordbookScreen(
        flashcards: cards,
        prefsProvider: () async => prefs,
        bookmarkService: service,
      ),
    ));
    await tester.pumpAndSettle();

    final pageViewFinder5 = find.byType(PageView);
    expect(pageViewFinder5, findsOneWidget);
    await tester.tap(pageViewFinder5);
    await tester.pumpAndSettle();
    expect(find.byType(SliderTheme), findsOneWidget);

    final listFinder = find.byIcon(Icons.list);
    expect(listFinder, findsOneWidget);
    await tester.tap(listFinder);
    await tester.pumpAndSettle();
    final jumpFinder = find.text('Page 2');
    expect(jumpFinder, findsOneWidget);
    await tester.tap(jumpFinder);
    await tester.pumpAndSettle();

    expect(find.text('(2 / 2)'), findsOneWidget);
  });
}
