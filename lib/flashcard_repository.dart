import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

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
}
