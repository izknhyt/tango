import 'package:flutter/material.dart';

import '../models/word_deck.dart';
import '../widgets/word_deck_card.dart';
import '../manga_word_viewer.dart';
import 'manga_word_viewer.dart';

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
              Navigator.of(context).push(
                PageRouteBuilder(
                  fullscreenDialog: true,
                  pageBuilder: (_, __, ___) => MangaWordViewer(
                    words: deck.words,
                    initialIndex: 0,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
