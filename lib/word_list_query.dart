/// Query parameters for fetching flashcards.
///
/// Includes sorting, filtering and search text.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'flashcard_model.dart';

/// Sorting options for word lists.
enum SortType {
  syllabus,
  importance,
  wrong,
  unviewed,
  interval,
  ai,
}

/// Additional filters when fetching words.
enum WordFilter {
  unviewed,
  wrongOnly,
  favorite,
}

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

  /// True if any search text or filters are set.
  bool get hasAny => searchText.isNotEmpty || filters.isNotEmpty;

  /// Return the default empty query.
  WordListQuery reset() => const WordListQuery();

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

    double _aiScore(Flashcard c) {
      final daysSinceLast = c.lastReviewed != null
          ? DateTime.now().difference(c.lastReviewed!).inDays.toDouble()
          : 365.0;
      final views = c.correctCount + c.wrongCount;
      final base = c.importance * 2 + c.wrongCount + daysSinceLast / 30;
      return c.lastReviewed == null
          ? base + 3 - views * 0.1
          : base - views * 0.1;
    }

    switch (sort) {
      case SortType.syllabus:
        filtered.sort((a, b) => a.id.compareTo(b.id));
        break;
      case SortType.importance:
        filtered.sort((a, b) => b.importance.compareTo(a.importance));
        break;
      case SortType.wrong:
        filtered.sort((a, b) => b.wrongCount.compareTo(a.wrongCount));
        break;
      case SortType.unviewed:
        filtered.sort((a, b) {
          final aViews = a.correctCount + a.wrongCount;
          final bViews = b.correctCount + b.wrongCount;
          if (a.lastReviewed == null && b.lastReviewed != null) return -1;
          if (a.lastReviewed != null && b.lastReviewed == null) return 1;
          return aViews.compareTo(bViews);
        });
        break;
      case SortType.interval:
        filtered.sort((a, b) {
          final at = a.lastReviewed;
          final bt = b.lastReviewed;
          if (at == null && bt == null) return 0;
          if (at == null) return 1;
          if (bt == null) return -1;
          return at.compareTo(bt);
        });
        break;
      case SortType.ai:
        filtered.sort((a, b) => _aiScore(b).compareTo(_aiScore(a)));
        break;
    }

    return filtered;
  }
}
