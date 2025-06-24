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
  late final Future<List<Flashcard>> _allWordsFuture;
  @override
  void initState() {
    super.initState();
    // Load initial list with default review mode.
    Future(() => updateMode(ReviewMode.random));
    _allWordsFuture = FlashcardRepository.loadAll();
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
    return FutureBuilder<List<Flashcard>>(
      future: _allWordsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || words == null) {
          return const Center(child: CircularProgressIndicator());
        }
          final all = snapshot.data!;
        final filtered = query.apply(words);

        return CustomScrollView(
          slivers: [
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
