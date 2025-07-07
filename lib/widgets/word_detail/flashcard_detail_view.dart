import 'package:flutter/material.dart';

import '../../flashcard_model.dart';
import '../../star_color.dart';
import '../detail_item.dart';
import '../favorite_star_button.dart';
import 'related_terms_section.dart';

class FlashcardDetailView extends StatelessWidget {
  final Flashcard card;
  final Map<StarColor, bool> favoriteStatus;
  final ValueChanged<StarColor> onToggleFavorite;
  final List<Flashcard> relatedSource;
  final void Function(Flashcard origin, Flashcard selected) onSelectRelated;

  const FlashcardDetailView({
    super.key,
    required this.card,
    required this.favoriteStatus,
    required this.onToggleFavorite,
    required this.relatedSource,
    required this.onSelectRelated,
  });

  @override
  Widget build(BuildContext context) {
    String categories =
        '${card.categoryLarge} > ${card.categoryMedium} > ${card.categorySmall}';
    if (card.categoryItem != card.categorySmall &&
        card.categoryItem.isNotEmpty &&
        !['（小分類全体）', '[脅威の種類]', '[マルウェア・不正プログラム]', 'nan', 'ー']
            .contains(card.categoryItem)) {
      categories += ' > ${card.categoryItem}';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  card.term,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FavoriteStarButton(
                    isFavorite: favoriteStatus[StarColor.red] ?? false,
                    activeColor: Theme.of(context).colorScheme.error,
                    inactiveColor: Theme.of(context).colorScheme.outline,
                    onPressed: () => onToggleFavorite(StarColor.red),
                    tooltip: '赤星',
                  ),
                  FavoriteStarButton(
                    isFavorite: favoriteStatus[StarColor.yellow] ?? false,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    inactiveColor: Theme.of(context).colorScheme.outline,
                    onPressed: () => onToggleFavorite(StarColor.yellow),
                    tooltip: '黄星',
                  ),
                  FavoriteStarButton(
                    isFavorite: favoriteStatus[StarColor.blue] ?? false,
                    activeColor: Theme.of(context).colorScheme.primary,
                    inactiveColor: Theme.of(context).colorScheme.outline,
                    onPressed: () => onToggleFavorite(StarColor.blue),
                    tooltip: '青星',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (card.reading.isNotEmpty && card.reading != 'nan' && card.reading != 'ー')
            Text(
              '読み: ${card.reading}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color,
                  ),
            ),
          const SizedBox(height: 12),
          DetailItem(
            label: '重要度:',
            value: '★' * card.importance.toInt() +
                (card.importance - card.importance.toInt() > 0 ? '☆' : '') +
                ' (${card.importance.toStringAsFixed(1)})',
          ),
          DetailItem(label: 'カテゴリー:', value: categories),
          const Divider(height: 24, thickness: 0.8),
          DetailItem(label: '概要 (Description):', value: card.description),
          DetailItem(label: '解説 (Practical Tip):', value: card.practicalTip),
          DetailItem(label: '出題例 (Exam Example):', value: card.examExample),
          DetailItem(label: '試験ポイント (Exam Point):', value: card.examPoint),
          RelatedTermsSection(
            card: card,
            source: relatedSource,
            onSelected: onSelectRelated,
          ),
          DetailItem(label: 'タグ (Tags):', value: card.tags?.join('、')),
        ],
      ),
    );
  }
}
