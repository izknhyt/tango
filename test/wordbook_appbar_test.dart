import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:tango/flashcard_model.dart';
import 'package:tango/models/bookmark.dart';
import 'package:tango/services/bookmark_service.dart';
import 'package:tango/constants.dart';
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
  late Directory tempDir;
  late Box<Bookmark> box;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(BookmarkAdapter().typeId)) {
      Hive.registerAdapter(BookmarkAdapter());
    }
    box = await Hive.openBox<Bookmark>(bookmarksBoxName);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk(bookmarksBoxName);
    await Hive.close();
    await tempDir.delete(recursive: true);
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
