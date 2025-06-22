import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

import 'history_entry_model.dart';
import 'word_list_query.dart';

import 'flashcard_model.dart';

/// Interface for a flashcard data source.
abstract class FlashcardDataSource {
  Future<List<Flashcard>> loadAll();
}

/// Load flashcards from the bundled JSON file.
class LocalFlashcardDataSource implements FlashcardDataSource {
  @override
  Future<List<Flashcard>> loadAll() async {
    final jsonString = await rootBundle.loadString('assets/words.json');
    final List<dynamic> jsonData = json.decode(jsonString) as List<dynamic>;
    List<Flashcard> cards = [];
    for (var item in jsonData) {
      if (item is Map<String, dynamic> &&
          item['id'] != null &&
          item['term'] != null) {
        try {
          cards.add(Flashcard.fromJson(item));
        } catch (_) {}
      }
    }
    return cards;
  }
}

/// Load flashcards from a remote HTTP endpoint.
class RemoteFlashcardDataSource implements FlashcardDataSource {
  final String url;
  final http.Client _client;

  RemoteFlashcardDataSource(this.url, {http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<Flashcard>> loadAll() async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load flashcards');
    }
    final List<dynamic> jsonData =
        json.decode(response.body) as List<dynamic>;
    List<Flashcard> cards = [];
    for (var item in jsonData) {
      if (item is Map<String, dynamic> &&
          item['id'] != null &&
          item['term'] != null) {
        try {
          cards.add(Flashcard.fromJson(item));
        } catch (_) {}
      }
    }
    return cards;
  }
}

/// Repository that caches flashcards loaded from a data source.
class FlashcardRepository {

  static FlashcardDataSource _dataSource = LocalFlashcardDataSource();
  static List<Flashcard>? _cache;
  static const String historyBoxName = 'history_box_v2';
  static const String quizStatsBoxName = 'quiz_stats_box_v1';

  /// Replace the current data source and clear the cache.
  static void setDataSource(FlashcardDataSource source) {
    _dataSource = source;
    _cache = null;
  }

  /// Load all flashcards. Results are cached after the first read.
  static Future<List<Flashcard>> loadAll() async {
    if (_cache != null) {
      return _cache!;
    }
    _cache = await _dataSource.loadAll();
    return _cache!;
  }

  /// Fetch flashcards matching [query].
  static Future<List<Flashcard>> fetch(WordListQuery query) async {
    final all = await loadAll();
    final historyBox = Hive.box<HistoryEntry>(historyBoxName);
    final quizStatsBox = Hive.box<Map>(quizStatsBoxName);

    final viewedIds = historyBox.values.map((e) => e.wordId).toSet();

    final Map<String, int> wrongCounts = {};
    for (final m in quizStatsBox.values) {
      final ids = (m['wordIds'] as List?)?.cast<String>() ?? [];
      final results = (m['results'] as List?)?.cast<bool>() ?? [];
      for (int i = 0; i < ids.length && i < results.length; i++) {
        if (results[i] == false) {
          wrongCounts[ids[i]] = (wrongCounts[ids[i]] ?? 0) + 1;
        }
      }
    }

    final Map<String, DateTime> lastReviewed = {};
    for (final e in historyBox.values) {
      final prev = lastReviewed[e.wordId];
      if (prev == null || e.timestamp.isAfter(prev)) {
        lastReviewed[e.wordId] = e.timestamp;
      }
    }

    final String q = query.searchText.trim().toLowerCase();

    List<Flashcard> result = all.where((card) {
      final matchesQuery = q.isEmpty ||
          card.term.toLowerCase().contains(q) ||
          card.reading.toLowerCase().contains(q);
      bool passesFilter = true;
      if (query.filters.contains(WordFilter.unviewed)) {
        passesFilter = passesFilter && !viewedIds.contains(card.id);
      }
      if (query.filters.contains(WordFilter.wrongOnly)) {
        passesFilter = passesFilter && (wrongCounts[card.id] ?? 0) > 0;
      }
      return matchesQuery && passesFilter;
    }).toList();

    switch (query.sort) {
      case SortType.id:
        result.sort((a, b) => a.id.compareTo(b.id));
        break;
      case SortType.importance:
        result.sort((a, b) => b.importance.compareTo(a.importance));
        break;
      case SortType.lastReviewed:
        result.sort((a, b) {
          final at = lastReviewed[a.id];
          final bt = lastReviewed[b.id];
          if (at == null && bt == null) return 0;
          if (at == null) return 1;
          if (bt == null) return -1;
          return bt.compareTo(at);
        });
        break;
    }

    return result;
  }
}
