import 'package:flutter/material.dart';

import '../models/word_deck.dart';
import '../widgets/word_deck_card.dart';
import '../wordbook_screen.dart';
import '../models/word.dart';

class WordbookLibraryPage extends StatelessWidget {
  final List<WordDeck> decks;

  const WordbookLibraryPage({super.key, required this.decks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('単語帳ライブラリ')),
      body: GridView.builder(
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
      ),
    );
  }
}
