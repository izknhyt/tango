import 'word_list_query.dart';

import 'flashcard_model.dart';
import 'services/flashcard_loader.dart';

/// Repository that caches flashcards loaded from a loader.
class FlashcardRepository {
  FlashcardLoader _loader;
  List<Flashcard>? _cache;

  FlashcardRepository({required FlashcardLoader loader}) : _loader = loader;

  static Future<FlashcardRepository> open({FlashcardLoader? loader}) async {
    final l = loader ?? await HiveFlashcardLoader.open();
    return FlashcardRepository(loader: l);
  }

  /// Replace the current loader and clear the cache.
  void setLoader(FlashcardLoader loader) {
    _loader = loader;
    _cache = null;
  }

  /// Load all flashcards. Results are cached after the first read.
  Future<List<Flashcard>> loadAll() async {
    if (_cache != null) {
      return _cache!;
    }
    _cache = await _loader.loadAll();
    return _cache!;
  }

  /// Fetch flashcards matching [query].
  Future<List<Flashcard>> fetch(WordListQuery query) async {
    final all = await loadAll();
    return query.apply(all);
  }
}
