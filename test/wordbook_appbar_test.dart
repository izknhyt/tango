
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:tango/flashcard_model.dart';
import 'package:tango/models/bookmark.dart';
import 'package:tango/models/review_queue.dart';
import 'package:tango/history_entry_model.dart';
import 'package:tango/services/bookmark_service.dart';
import 'package:tango/constants.dart';
import 'package:tango/wordbook_screen.dart';
import 'test_harness.dart';

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
  initTestHarness();
  late Box<Bookmark> box;

  setUp(() async {
    box = Hive.box<Bookmark>(bookmarksBoxName);
  });

  tearDown(() async {
    await box.clear();
  });

  testWidgets('shows current page indicator in AppBar', (tester) async {
    final cards = List.generate(861, (i) => _card(i + 1));
    SharedPreferences.setMockInitialValues({'bookmark_pageIndex': 77});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MaterialApp(
        home: WordbookScreen(
      flashcards: cards,
      prefsProvider: () async => prefs,
      bookmarkService: BookmarkService(box),
    )));
    await tester.pumpAndSettle();
    expect(find.text('(78 / 861)'), findsOneWidget);
  });
}
