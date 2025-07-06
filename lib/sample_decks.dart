import 'flashcard_model.dart';
import 'flashcard_repository.dart';
import 'models/word.dart';
import 'models/word_deck.dart';

Word _toWord(Flashcard fc) {
  return Word(
    id: fc.id,
    term: fc.term,
    reading: fc.reading,
    description: fc.description,
    relatedIds: fc.relatedIds,
    tags: fc.tags,
    examExample: fc.examExample,
    examPoint: fc.examPoint,
    practicalTip: fc.practicalTip,
    categoryLarge: fc.categoryLarge,
    categoryMedium: fc.categoryMedium,
    categorySmall: fc.categorySmall,
    categoryItem: fc.categoryItem,
    importance: fc.importance,
    english: fc.english,
  );
}

/// Load the default word decks from the bundled JSON.
Future<List<WordDeck>> loadDefaultDecks(FlashcardRepository repo) async {
  final cards = await repo.loadAll();
  final words = cards.map(_toWord).toList();
  return [WordDeck(title: '全単語帳', words: words)];
}
