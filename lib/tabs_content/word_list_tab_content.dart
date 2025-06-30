import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../flashcard_model.dart';
import '../word_list_query.dart';
import '../review_service.dart';
import '../word_query_sheet.dart';
import '../star_color.dart';

/// Provider storing the list of words for the current [ReviewMode].
final wordListForModeProvider = StateProvider<List<Flashcard>?>(
  (ref) => null,
);

/// Tab displaying all flashcards with search, sort and filter options.
class WordListTabContent extends ConsumerStatefulWidget {
  /// Called when a word card is tapped.
  final void Function(List<Flashcard>, int) onWordTap;

  const WordListTabContent({Key? key, required this.onWordTap})
      : super(key: key);

  @override
  ConsumerState<WordListTabContent> createState() => WordListTabContentState();
}

class WordListTabContentState extends ConsumerState<WordListTabContent> {
  @override
  void initState() {
    super.initState();
    // Load initial list with default review mode.
    Future(() => updateMode(ReviewMode.random));
  }

  /// Show bottom sheet to edit the current [WordListQuery].
  Future<void> _openQuerySheet(BuildContext context) async {
    final current = ref.read(currentQueryProvider);
    final result = await showWordQuerySheet(context, current);
    if (result != null && mounted) {
      ref.read(currentQueryProvider.notifier).state = result;
    }
  }

  // Search dialog removed. Opening the query sheet now handles search text.

  @override
  Widget build(BuildContext context) {
    final words = ref.watch(wordListForModeProvider);
    final query = ref.watch(currentQueryProvider);
    if (words == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final all = words;
    final filtered = query.apply(words);
    return CustomScrollView(
      slivers: [
        if (query.hasAny)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    if (query.searchText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: InputChip(
                          label: Text(query.searchText),
                          onDeleted: () => ref
                              .read(currentQueryProvider.notifier)
                              .state = query.copyWith(searchText: ''),
                        ),
                      ),
                    if (query.filters.contains(WordFilter.unviewed))
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: InputChip(
                          label: const Text('未閲覧'),
                          onDeleted: () {
                            final newFilters = {...query.filters}
                              ..remove(WordFilter.unviewed);
                            ref.read(currentQueryProvider.notifier).state =
                                query.copyWith(filters: newFilters);
                          },
                        ),
                      ),
                    if (query.filters.contains(WordFilter.wrongOnly))
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: InputChip(
                          label: const Text('間違えのみ'),
                          onDeleted: () {
                            final newFilters = {...query.filters}
                              ..remove(WordFilter.wrongOnly);
                            ref.read(currentQueryProvider.notifier).state =
                                query.copyWith(filters: newFilters);
                          },
                        ),
                      ),
                    if (query.favoritesOnly)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: InputChip(
                          label: const Text('お気に入り'),
                          onDeleted: () {
                            ref.read(currentQueryProvider.notifier).state =
                                query.copyWith(
                                    favoritesOnly: false,
                                    starFilters: const {});
                          },
                        ),
                      ),
                    if (query.favoritesOnly &&
                        query.starFilters.contains(StarColor.red))
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: InputChip(
                          label: const Text('赤星'),
                          onDeleted: () {
                            final colors = {...query.starFilters}
                              ..remove(StarColor.red);
                            ref.read(currentQueryProvider.notifier).state =
                                query.copyWith(starFilters: colors);
                          },
                        ),
                      ),
                    if (query.favoritesOnly &&
                        query.starFilters.contains(StarColor.yellow))
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: InputChip(
                          label: const Text('黄星'),
                          onDeleted: () {
                            final colors = {...query.starFilters}
                              ..remove(StarColor.yellow);
                            ref.read(currentQueryProvider.notifier).state =
                                query.copyWith(starFilters: colors);
                          },
                        ),
                      ),
                    if (query.favoritesOnly &&
                        query.starFilters.contains(StarColor.blue))
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: InputChip(
                          label: const Text('青星'),
                          onDeleted: () {
                            final colors = {...query.starFilters}
                              ..remove(StarColor.blue);
                            ref.read(currentQueryProvider.notifier).state =
                                query.copyWith(starFilters: colors);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        if (filtered.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                query.searchText.isEmpty && all.isEmpty
                    ? '登録されている単語がありません。'
                    : '検索結果に一致する単語がありません。',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          SliverList.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final card = filtered[index];
              return Semantics(
                button: true,
                label: card.term,
                child: ListTile(
                  title: Text(card.term),
                  subtitle: Text(
                    card.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => widget.onWordTap(filtered, index),
                ),
              );
            },
          ),
      ],
    );
  }

  /// Exposed for backward compatibility with [MainScreen].
  void openFilterSheet(BuildContext context) => _openQuerySheet(context);

  /// Update the displayed word list based on the given [ReviewMode].
  void updateMode(ReviewMode mode) async {
    // Immediately clear the current list while loading new data.
    ref.read(wordListForModeProvider.notifier).state = null;
    final service = ReviewService();
    final list = await service.fetchForMode(mode);
    if (!mounted) return;
    ref.read(wordListForModeProvider.notifier).state = list;
  }
}
