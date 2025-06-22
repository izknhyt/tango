import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as badges;

import '../flashcard_model.dart';
import '../flashcard_repository.dart';
import '../word_list_query.dart';
import '../review_service.dart';

/// Provider keeping the current [WordListQuery].
final wordListQueryProvider =
    StateProvider<WordListQuery>((ref) => const WordListQuery());

/// Tab displaying all flashcards with search, sort and filter options.
class WordListTabContent extends ConsumerStatefulWidget {
  /// Called when a word card is tapped.
  final void Function(List<Flashcard>, int) onWordTap;

  const WordListTabContent({Key? key, required this.onWordTap}) : super(key: key);

  @override
  ConsumerState<WordListTabContent> createState() => WordListTabContentState();
}

class WordListTabContentState extends ConsumerState<WordListTabContent> {
  /// Show bottom sheet to edit the current [WordListQuery].
  void _openQuerySheet(BuildContext context) {
    final current = ref.read(wordListQueryProvider);
    SortType sort = current.sort;
    final Set<WordFilter> filters = {...current.filters};
    final controller = TextEditingController(text: current.searchText);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            labelText: '検索語',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: SortType.values
                              .map(
                                (m) => RadioListTile<SortType>(
                                  title: Text(_labelForSort(m)),
                                  value: m,
                                  groupValue: sort,
                                  onChanged: (v) => setState(() {
                                    if (v != null) sort = v;
                                  }),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 8,
                          children: [
                            FilterChip(
                              label: const Text('未閲覧'),
                              selected: filters.contains(WordFilter.unviewed),
                              onSelected: (val) {
                                setState(() {
                                  if (val) {
                                    filters.add(WordFilter.unviewed);
                                  } else {
                                    filters.remove(WordFilter.unviewed);
                                  }
                                });
                              },
                            ),
                            FilterChip(
                              label: const Text('間違えのみ'),
                              selected: filters.contains(WordFilter.wrongOnly),
                              onSelected: (val) {
                                setState(() {
                                  if (val) {
                                    filters.add(WordFilter.wrongOnly);
                                  } else {
                                    filters.remove(WordFilter.wrongOnly);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                ref.read(wordListQueryProvider.notifier).state =
                                    current.copyWith(
                                  searchText: controller.text,
                                  sort: sort,
                                  filters: filters,
                                );
                                Navigator.of(ctx).pop();
                              },
                              child: const Text('適用'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Show a dialog to edit only the search text.
  void _openSearchDialog(BuildContext context) {
    final controller =
        TextEditingController(text: ref.read(wordListQueryProvider).searchText);
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
                ref.read(wordListQueryProvider.notifier).state =
                    ref.read(wordListQueryProvider).copyWith(
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

  String _labelForSort(SortType type) {
    switch (type) {
      case SortType.id:
        return 'ID順';
      case SortType.importance:
        return '重要度順';
      case SortType.lastReviewed:
        return '最終閲覧順';
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(wordListQueryProvider);
    final future = Future.wait([
      FlashcardRepository.loadAll(),
      FlashcardRepository.fetch(query),
    ]);

    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final all = snapshot.data![0] as List<Flashcard>;
        final filtered = snapshot.data![1] as List<Flashcard>;

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
                            ref.read(wordListQueryProvider.notifier).state =
                                query.copyWith(searchText: ''),
                      ),
                    if (query.filters.contains(WordFilter.unviewed))
                      InputChip(
                        label: const Text('未閲覧'),
                        onDeleted: () {
                          final newFilters = {...query.filters}
                            ..remove(WordFilter.unviewed);
                          ref
                              .read(wordListQueryProvider.notifier)
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
                              .read(wordListQueryProvider.notifier)
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

  /// Placeholder to keep compatibility with older [ReviewMode] logic.
  void updateMode(ReviewMode mode) {}
}
