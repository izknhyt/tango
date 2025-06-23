/// Query parameters for fetching flashcards.
///
/// Includes sorting, filtering and search text.

/// Sorting options for word lists.
enum SortType { id, importance, lastReviewed }

/// Additional filters when fetching words.
enum WordFilter { unviewed, wrongOnly }

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global provider storing the current [WordListQuery].
final currentQueryProvider =
    StateProvider<WordListQuery>((ref) => const WordListQuery());

/// Query used by [FlashcardRepository.fetch] to obtain filtered words.
class WordListQuery {
  /// Text used to search `term` or `reading` fields.
  final String searchText;

  /// Type of sorting to apply when returning results.
  final SortType sort;

  /// Filters to apply while fetching words.
  final Set<WordFilter> filters;

  /// Create a new query.
  const WordListQuery({
    this.searchText = '',
    this.sort = SortType.importance,
    this.filters = const {},
  });

  /// Return a copy with updated fields.
  WordListQuery copyWith({
    String? searchText,
    SortType? sort,
    Set<WordFilter>? filters,
  }) {
    return WordListQuery(
      searchText: searchText ?? this.searchText,
      sort: sort ?? this.sort,
      filters: filters ?? this.filters,
    );
  }

  /// Apply this query to [cards], returning a filtered and sorted list.
  List<Flashcard> apply(List<Flashcard> cards) {
    final q = searchText.trim().toLowerCase();
    final filtered = cards.where((card) {
      final matchesQuery = q.isEmpty ||
          card.term.toLowerCase().contains(q) ||
          card.reading.toLowerCase().contains(q);
      bool passesFilter = true;
      if (filters.contains(WordFilter.unviewed)) {
        passesFilter &= card.lastReviewed == null;
      }
      if (filters.contains(WordFilter.wrongOnly)) {
        passesFilter &= card.wrongCount > 0;
      }
      return matchesQuery && passesFilter;
    }).toList();

    switch (sort) {
      case SortType.id:
        filtered.sort((a, b) => a.id.compareTo(b.id));
        break;
      case SortType.importance:
        filtered.sort((a, b) => b.importance.compareTo(a.importance));
        break;
      case SortType.lastReviewed:
        filtered.sort((a, b) {
          final at = a.lastReviewed;
          final bt = b.lastReviewed;
          if (at == null && bt == null) return 0;
          if (at == null) return 1;
          if (bt == null) return -1;
          return bt.compareTo(at);
        });
        break;
    }

    return filtered;
  }
}
