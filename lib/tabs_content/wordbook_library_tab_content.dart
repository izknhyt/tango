import 'package:flutter/material.dart';

import '../models/word.dart';
import '../models/word_deck.dart';
import '../manga_word_viewer.dart';
import '../widgets/word_deck_card.dart';
import '../wordbook_screen.dart';

class WordbookLibraryTabContent extends StatelessWidget {
  final List<WordDeck> decks;

  const WordbookLibraryTabContent({super.key, required this.decks});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: decks.length,
      itemBuilder: (context, index) {
        final deck = decks[index];
        return WordDeckCard(
          deck: deck,
          onTap: () {
            final flashcards = deck.words.map((w) => w.toFlashcard()).toList();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WordbookScreen(flashcards: flashcards),
              ),
            );
          },
        );
      },
    );
  }
}
