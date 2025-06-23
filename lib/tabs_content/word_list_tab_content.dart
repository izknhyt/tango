import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as badges;

import '../flashcard_model.dart';
import '../flashcard_repository.dart';
import '../word_list_query.dart';
import '../review_service.dart';
import '../word_query_sheet.dart';

/// Provider storing the list of words for the current [ReviewMode].
final wordListForModeProvider =
    StateProvider<List<Flashcard>?>(
  (ref) => null,
);

/// Tab displaying all flashcards with search, sort and filter options.
class WordListTabContent extends ConsumerStatefulWidget {
  /// Called when a word card is tapped.
  final void Function(List<Flashcard>, int) onWordTap;

  const WordListTabContent({Key? key, required this.onWordTap}) : super(key: key);

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

  /// Show a dialog to edit only the search text.
  void _openSearchDialog(BuildContext context) {
    final controller =
        TextEditingController(text: ref.read(currentQueryProvider).searchText);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('検索'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: '単語名または読み方で検索...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(currentQueryProvider.notifier).state =
                    ref.read(currentQueryProvider).copyWith(
                          searchText: controller.text,
                        );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final words = ref.watch(wordListForModeProvider);
    final query = ref.watch(currentQueryProvider);
    return FutureBuilder<List<Flashcard>>( 
      future: FlashcardRepository.loadAll(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || words == null) {
          return const Center(child: CircularProgressIndicator());
        }
          final all = snapshot.data!;
        final filtered = query.apply(words);

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              title:
                  Text('表示中 ${filtered.length} / 全 ${all.length} 単語'),
              actions: [
                Semantics(
                  label: '検索',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _openSearchDialog(context),
                  ),
                ),
                Semantics(
                  label: '並び替え',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.sort),
                    onPressed: () => _openQuerySheet(context),
                  ),
                ),
                Semantics(
                  label: 'フィルター',
                  button: true,
                  child: badges.Badge(
                    badgeContent: Text('${query.filters.length}'),
                    showBadge: query.filters.isNotEmpty,
                    child: IconButton(
                      icon: const Icon(Icons.filter_alt_outlined),
                      onPressed: () => _openQuerySheet(context),
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Wrap(
                  spacing: 4,
                  children: [
                    if (query.searchText.isNotEmpty)
                      InputChip(
                        label: Text(query.searchText),
                        onDeleted: () =>
                            ref.read(currentQueryProvider.notifier).state =
                                query.copyWith(searchText: ''),
                      ),
                    if (query.filters.contains(WordFilter.unviewed))
                      InputChip(
                        label: const Text('未閲覧'),
                        onDeleted: () {
                          final newFilters = {...query.filters}
                            ..remove(WordFilter.unviewed);
                          ref
                              .read(currentQueryProvider.notifier)
                              .state = query.copyWith(filters: newFilters);
                        },
                      ),
                    if (query.filters.contains(WordFilter.wrongOnly))
                      InputChip(
                        label: const Text('間違えのみ'),
                        onDeleted: () {
                          final newFilters = {...query.filters}
                            ..remove(WordFilter.wrongOnly);
                          ref
                              .read(currentQueryProvider.notifier)
                              .state = query.copyWith(filters: newFilters);
                        },
                      ),
                  ],
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
      },
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
