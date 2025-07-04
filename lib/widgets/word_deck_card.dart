import 'package:flutter/material.dart';

import '../models/word_deck.dart';

class WordDeckCard extends StatelessWidget {
  final WordDeck deck;
  final VoidCallback onTap;

  const WordDeckCard({
    super.key,
    required this.deck,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              deck.title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('${deck.words.length}語'),
          ],
        ),
      ),
    );

    return Center(
      child: InkWell(
        onTap: onTap,
        child: card,
      ),
    );
  }
}
