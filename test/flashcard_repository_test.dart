import 'package:flutter_test/flutter_test.dart';
import 'package:tango/flashcard_model.dart';
import 'package:tango/flashcard_repository.dart';
import 'package:tango/services/flashcard_loader.dart';

class _FakeLoader implements FlashcardLoader {
  int calls = 0;
  final List<Flashcard> cards;
  _FakeLoader(this.cards);

  @override
  Future<List<Flashcard>> loadAll() async {
    calls++;
    return cards;
  }
}

void main() {
  test('FlashcardRepository caches results', () async {
    final loader = _FakeLoader([
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
    final repo = FlashcardRepository(loader: loader);
    final first = await repo.loadAll();
    final second = await repo.loadAll();
    expect(loader.calls, 1);
    expect(identical(first, second), isTrue);
  });
}
