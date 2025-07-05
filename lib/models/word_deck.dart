import 'word.dart';

/// A container for a set of related words shown in the wordbook library.

class WordDeck {
  final String title;
  final List<Word> words;

  WordDeck({
    required this.title,
    required this.words,
  });
}
