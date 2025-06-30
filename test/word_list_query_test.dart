import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:tango/flashcard_model.dart';
import 'package:tango/word_list_query.dart';
import 'package:tango/star_color.dart';
import 'package:tango/constants.dart';

void main() {
  late Directory dir;
  late Box<Map> favBox;

  final card1 = Flashcard(
    id: '1',
    term: 'a',
    reading: 'a',
    description: 'd',
    categoryLarge: 'A',
    categoryMedium: 'B',
    categorySmall: 'C',
    categoryItem: 'D',
    importance: 1,
    lastReviewed: DateTime.now().subtract(const Duration(days: 10)),
    wrongCount: 1,
    correctCount: 1,
  );
  final card2 = Flashcard(
    id: '2',
    term: 'b',
    reading: 'b',
    description: 'd',
    categoryLarge: 'A',
    categoryMedium: 'B',
    categorySmall: 'C',
    categoryItem: 'D',
    importance: 3,
    lastReviewed: null,
    wrongCount: 2,
    correctCount: 0,
  );
  final card3 = Flashcard(
    id: '3',
    term: 'c',
    reading: 'c',
    description: 'd',
    categoryLarge: 'A',
    categoryMedium: 'B',
    categorySmall: 'C',
    categoryItem: 'D',
    importance: 2,
    lastReviewed: DateTime.now().subtract(const Duration(days: 30)),
    wrongCount: 0,
    correctCount: 5,
  );
  final cards = [card1, card2, card3];

  setUp(() async {
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    favBox = await Hive.openBox<Map>(favoritesBoxName);
    await favBox.put('1', {'red': true});
    await favBox.put('2', {'yellow': true});
    await favBox.put('3', {'blue': true});
  });

  tearDown(() async {
    await favBox.close();
    await Hive.deleteBoxFromDisk(favoritesBoxName);
    await dir.delete(recursive: true);
  });

  test('unviewed sort prioritizes unseen cards', () {
    final query = const WordListQuery(sort: SortType.unviewed);
    final sorted = query.apply(cards);
    expect(sorted.first.id, '2');
  });

  test('interval sort orders by oldest first', () {
    final query = const WordListQuery(sort: SortType.interval);
    final sorted = query.apply(cards);
    expect(sorted.map((c) => c.id).take(2), ['3', '1']);
    expect(sorted.last.id, '2');
  });

  test('AI sort places high priority first', () {
    final query = const WordListQuery(sort: SortType.ai);
    final sorted = query.apply(cards);
    expect(sorted.first.id, '2');
  });

  test('favorite star filter with AND', () {
    final query = const WordListQuery(
      starFilters: {StarColor.red},
      starAnd: true,
    );
    final filtered = query.apply(cards);
    expect(filtered.length, 1);
    expect(filtered.first.id, '1');
  });

  test('favorite star filter with OR', () {
    final query = const WordListQuery(
      starFilters: {StarColor.red, StarColor.yellow},
      starAnd: false,
    );
    final filtered = query.apply(cards);
    expect(filtered.map((c) => c.id).toSet(), {'1', '2'});
  });
}
