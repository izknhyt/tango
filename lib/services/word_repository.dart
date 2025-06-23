import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';

import '../models/word.dart';

enum WordSort { kana, importance }

/// Repository for [Word] objects persisted in Hive.
class WordRepository {
  static const boxName = 'words_box_v1';

  final Box<Word> _box;

  WordRepository._(this._box);

  /// Open the Hive box used for words.
  static Future<WordRepository> open() async {
    final box = await Hive.openBox<Word>(boxName);
    return WordRepository._(box);
  }

  /// Seed words from a bundled JSON file if the box is empty.
  Future<void> seedFromAsset(String assetPath) async {
    if (_box.isNotEmpty) return;
    final jsonString = await rootBundle.loadString(assetPath);
    final List<dynamic> data = json.decode(jsonString) as List<dynamic>;
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        final word = Word.fromJson(item);
        await _box.put(word.id, word);
      }
    }
  }

  Future<void> add(Word word) async => _box.put(word.id, word);

  Word? get(String id) => _box.get(id);

  Future<void> delete(String id) async => _box.delete(id);

  /// Return all words sorted by [sort].
  List<Word> list({WordSort sort = WordSort.kana}) {
    final words = _box.values.toList();
    switch (sort) {
      case WordSort.kana:
        words.sort((a, b) => a.reading.compareTo(b.reading));
        break;
      case WordSort.importance:
        words.sort((a, b) => b.importance.compareTo(a.importance));
        break;
    }
    return words;
  }
}
