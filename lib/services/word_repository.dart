import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';
import 'package:tango/hive_utils.dart';

import '../models/word.dart';

/// Repository for [Word] objects persisted in Hive.
class WordRepository {
  static const boxName = 'words_box_v1';

  final Box<Word> _box;

  WordRepository._(this._box);

  /// Open the Hive box used for words.
  static Future<WordRepository> open() async {
    if (!Hive.isAdapterRegistered(WordAdapter().typeId)) {
      Hive.registerAdapter<Word>(WordAdapter());
    }

    try {
      final box = await openTypedBox<Word>(boxName);
      return WordRepository._(box);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to open $boxName: $e');
      rethrow;
    }
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

  /// Return all words in the box.
  List<Word> list() {
    return _box.values.toList();
  }
}
