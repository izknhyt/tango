import 'package:flutter/material.dart';

import '../../flashcard_model.dart';

class RelatedTermsSection extends StatelessWidget {
  final Flashcard card;
  final List<Flashcard> source;
  final void Function(Flashcard origin, Flashcard selected) onSelected;

  const RelatedTermsSection({
    super.key,
    required this.card,
    required this.source,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final ids = card.relatedIds;
    if (ids == null || ids.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Widget> buttons = [];
    for (final id in ids) {
      Flashcard? related;
      try {
        related = source.firstWhere((c) => c.id == id);
      } catch (_) {
        related = null;
      }
      final label = related?.term ?? id;
      buttons.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
          child: TextButton(
            onPressed: related != null
                ? () => _showDialog(context, related!, card)
                : null,
            child: Text(label),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '関連用語 (Related Terms):',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 4),
          Wrap(children: buttons),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, Flashcard selected, Flashcard origin) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
          onSelected(origin, selected);
        },
        child: AlertDialog(
          title: Text(selected.term),
          content: Text(selected.description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        ),
      ),
    );
  }
}
