import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'flashcard_model.dart';

class FlashcardRepository {
  static List<Flashcard>? _cache;

  /// Load all flashcards from assets/words.json.
  /// The result is cached after the first read.
  static Future<List<Flashcard>> loadAll() async {
    if (_cache != null) {
      return _cache!;
    }
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
    _cache = cards;
    return cards;
  }
}
