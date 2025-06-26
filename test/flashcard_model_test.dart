import 'package:flutter_test/flutter_test.dart';
import 'package:tango/flashcard_model.dart';

void main() {
  test('fromJson handles snake_case keys', () {
    final json = {
      'id': '1',
      'term': 'Test',
      'reading': 'test',
      'description': 'desc',
      'category_large': 'A',
      'category_medium': 'B',
      'category_small': 'C',
      'category_item': 'D',
      'importance': 2,
    };
    final card = Flashcard.fromJson(json);
    expect(card.categoryLarge, 'A');
    expect(card.categoryMedium, 'B');
    expect(card.categoryItem, 'D');
    expect(card.importance, 2);
  });

  test('fromJson parses comma separated lists', () {
    final json = {
      'id': '2',
      'term': 'List',
      'reading': 'list',
      'description': 'desc',
      'relatedIds': 'a,b,c',
      'categoryLarge': 'A',
      'categoryMedium': 'B',
      'categorySmall': 'C',
      'categoryItem': 'D',
      'importance': 1,
    };
    final card = Flashcard.fromJson(json);
    expect(card.relatedIds, ['a', 'b', 'c']);
  });
}
