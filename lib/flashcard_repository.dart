import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'word_list_query.dart';

import 'flashcard_model.dart';
import 'services/word_repository.dart';
import 'services/learning_repository.dart';

List<Flashcard> _parseFlashcards(List<dynamic> jsonData) {
  final cards = <Flashcard>[];
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
    return _parseFlashcards(jsonData);
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
    final List<dynamic> jsonData = json.decode(response.body) as List<dynamic>;
    return _parseFlashcards(jsonData);
  }
}

/// Repository that caches flashcards loaded from a data source.
class FlashcardRepository {
  FlashcardDataSource _dataSource;
  List<Flashcard>? _cache;
  final WordRepository _wordRepo;
  final LearningRepository _learningRepo;

  FlashcardRepository({
    FlashcardDataSource? dataSource,
    required WordRepository wordRepo,
    required LearningRepository learningRepo,
  })  : _dataSource = dataSource ?? LocalFlashcardDataSource(),
        _wordRepo = wordRepo,
        _learningRepo = learningRepo;

  static Future<FlashcardRepository> open({
    FlashcardDataSource? dataSource,
    WordRepository? wordRepo,
    LearningRepository? learningRepo,
  }) async {
    final wr = wordRepo ?? await WordRepository.open();
    await wr.seedFromAsset('assets/words.json');
    final lr = learningRepo ?? await LearningRepository.open();
    return FlashcardRepository(
      dataSource: dataSource,
      wordRepo: wr,
      learningRepo: lr,
    );
  }

  /// Replace the current data source and clear the cache.
  void setDataSource(FlashcardDataSource source) {
    _dataSource = source;
    _cache = null;
  }

  /// Load all flashcards. Results are cached after the first read.
  Future<List<Flashcard>> loadAll() async {
    if (_cache != null) {
      return _cache!;
    }
    final words = _wordRepo.list();
    words.sort((a, b) => a.id.compareTo(b.id));
    final stats = {for (var s in _learningRepo.all()) s.wordId: s};
    _cache = words.map((w) {
      final stat = stats[w.id];
      return Flashcard(
        id: w.id,
        term: w.term,
        english: w.english,
        reading: w.reading,
        description: w.description,
        relatedIds: w.relatedIds,
        tags: w.tags,
        examExample: w.examExample,
        examPoint: w.examPoint,
        practicalTip: w.practicalTip,
        categoryLarge: w.categoryLarge,
        categoryMedium: w.categoryMedium,
        categorySmall: w.categorySmall,
        categoryItem: w.categoryItem,
        importance: w.importance,
        lastReviewed: stat?.lastReviewed,
        wrongCount: stat?.wrongCount ?? 0,
        correctCount: stat?.correctCount ?? 0,
      );
    }).toList();
    return _cache!;
  }

  /// Fetch flashcards matching [query].
  Future<List<Flashcard>> fetch(WordListQuery query) async {
    final all = await loadAll();
    return query.apply(all);
  }
}
