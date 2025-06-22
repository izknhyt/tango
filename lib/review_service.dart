import 'dart:math';
import 'package:hive/hive.dart';

import 'flashcard_model.dart';
import 'flashcard_repository.dart';
import 'tag_stats.dart';

/// Hive box name storing per flashcard review state.
const String flashcardStateBoxName = 'flashcard_state_box';

/// Modes for selecting flashcards to review.
enum ReviewMode {
  newWords,
  random,
  wrongDescending,
  tagFocus,
  spacedRepetition,
  mixed,
  tagOnly,
  autoFilter,
}

/// Helper service for computing review priorities and fetching flashcards.
class ReviewService {
  final Box<Map> _stateBox;

  ReviewService() : _stateBox = Hive.box<Map>(flashcardStateBoxName);

  /// Merge saved state into a flashcard instance.
  Flashcard mergeState(Flashcard card) {
    final state = _stateBox.get(card.id);
    if (state == null) return card;
    return card.copyWith(
      lastReviewed: state['lastReviewed'] as DateTime?,
      nextDue: state['nextDue'] as DateTime?,
      wrongCount: state['wrongCount'] as int? ?? 0,
      correctCount: state['correctCount'] as int? ?? 0,
    );
  }

  /// Save state back to Hive.
  Future<void> saveState(Flashcard card) async {
    final state = {
      'lastReviewed': card.lastReviewed,
      'nextDue': card.nextDue,
      'wrongCount': card.wrongCount,
      'correctCount': card.correctCount,
    };
    await _stateBox.put(card.id, state);
  }

  /// Score based on how overdue a card is.
  double urgencyScore(Flashcard card) {
    final due = card.nextDue;
    if (due == null) return 0;
    return DateTime.now().difference(due).inHours.toDouble();
  }

  /// Score based on previous mistakes.
  double errorScore(Flashcard card) {
    final total = card.correctCount + card.wrongCount;
    if (total == 0) return 0;
    return card.wrongCount / total;
  }

  /// Weakness score for the first tag in the card.
  double tagWeakness(Flashcard card, Map<String, double> tagRates) {
    if (card.tags == null || card.tags!.isEmpty) return 0;
    return tagRates[card.tags!.first] ?? 0;
  }

  double priority(Flashcard card, Map<String, double> tagRates) {
    return urgencyScore(card) + errorScore(card) + tagWeakness(card, tagRates);
  }

  /// Compute error rates per tag from stored statistics.
  Map<String, double> computeTagRates(List<Flashcard> cards) {
    final Map<String, int> wrong = {};
    final Map<String, int> total = {};

    for (final state in _stateBox.values) {
      final statsMap = (state['tagStats'] as Map?)?.cast<String, dynamic>() ?? {};
      statsMap.forEach((tag, value) {
        final TagStats stats = TagStats.fromMap(value as Map);
        wrong[tag] = (wrong[tag] ?? 0) + stats.totalWrong;
        total[tag] = (total[tag] ?? 0) + stats.totalAttempts;
      });
    }

    // Ensure tags that exist on cards appear even if never attempted.
    for (final c in cards) {
      for (final t in c.tags ?? []) {
        wrong[t] = wrong[t] ?? 0;
        total[t] = total[t] ?? 0;
      }
    }

    final Map<String, double> rates = {};
    total.forEach((tag, count) {
      final w = wrong[tag] ?? 0;
      if (count > 0) {
        rates[tag] = w / count;
      }
    });
    return rates;
  }

  /// Load all flashcards with state merged in.
  Future<List<Flashcard>> _loadAllWithState() async {
    final cards = await FlashcardRepository.loadAll();
    return cards.map(mergeState).toList();
  }

  /// Return the top [limit] flashcards ranked by [priority].
  Future<List<Flashcard>> topByPriority(int limit) async {
    final cards = await _loadAllWithState();
    final tagRates = computeTagRates(cards);
    cards.sort((a, b) =>
        priority(b, tagRates).compareTo(priority(a, tagRates)));
    if (limit >= cards.length) return cards;
    return cards.sublist(0, limit);
  }

  /// Fetch cards for the given review mode.
  Future<List<Flashcard>> fetchForMode(ReviewMode mode) async {
    final cards = await _loadAllWithState();
    final tagRates = computeTagRates(cards);

    switch (mode) {
      case ReviewMode.newWords:
        return cards.where((c) => c.lastReviewed == null).toList();
      case ReviewMode.random:
        cards.shuffle(Random());
        return cards;
      case ReviewMode.wrongDescending:
        cards.sort((a, b) => b.wrongCount.compareTo(a.wrongCount));
        return cards;
      case ReviewMode.tagFocus:
        cards.sort((a, b) =>
            priority(b, tagRates).compareTo(priority(a, tagRates)));
        return cards;
      case ReviewMode.spacedRepetition:
        cards.sort((a, b) {
          final aDue = a.nextDue ?? DateTime.now();
          final bDue = b.nextDue ?? DateTime.now();
          return aDue.compareTo(bDue);
        });
        return cards;
      case ReviewMode.mixed:
        cards.sort((a, b) =>
            priority(b, tagRates).compareTo(priority(a, tagRates)));
        return cards;
      case ReviewMode.tagOnly:
        return cards.where((c) => c.tags != null && c.tags!.isNotEmpty).toList();
      case ReviewMode.autoFilter:
        cards.sort((a, b) =>
            priority(b, tagRates).compareTo(priority(a, tagRates)));
        return cards;
    }
  }
}
