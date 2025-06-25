import 'package:flutter_test/flutter_test.dart';
import 'package:tango/flashcard_model.dart';
import 'package:tango/word_list_query.dart';

void main() {
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
}
