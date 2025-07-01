import 'package:flutter_test/flutter_test.dart';
import 'package:tango/flashcard_model.dart';
import 'package:tango/flashcard_repository.dart';

class _FakeSource implements FlashcardDataSource {
  int calls = 0;
  final List<Flashcard> cards;
  _FakeSource(this.cards);

  @override
  Future<List<Flashcard>> loadAll() async {
    calls++;
    return cards;
  }
}

void main() {
  test('FlashcardRepository caches results', () async {
    final source = _FakeSource([
      Flashcard(
        id: '1',
        term: 'a',
        reading: 'a',
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
      ),
    ]);
    final repo = await FlashcardRepository.open(dataSource: source);
    final first = await repo.loadAll();
    final second = await repo.loadAll();
    expect(source.calls, 1);
    expect(identical(first, second), isTrue);
  });
}
