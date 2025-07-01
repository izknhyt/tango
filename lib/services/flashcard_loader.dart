import '../flashcard_model.dart';
import 'learning_repository.dart';
import 'word_repository.dart';

abstract class FlashcardLoader {
  Future<List<Flashcard>> loadAll();
}

class HiveFlashcardLoader implements FlashcardLoader {
  final WordRepository _wordRepo;
  final LearningRepository _learningRepo;

  HiveFlashcardLoader({required WordRepository wordRepo, required LearningRepository learningRepo})
      : _wordRepo = wordRepo,
        _learningRepo = learningRepo;

  static Future<HiveFlashcardLoader> open({WordRepository? wordRepo, LearningRepository? learningRepo}) async {
    final wr = wordRepo ?? await WordRepository.open();
    await wr.seedFromAsset('assets/words.json');
    final lr = learningRepo ?? await LearningRepository.open();
    return HiveFlashcardLoader(wordRepo: wr, learningRepo: lr);
  }

  @override
  Future<List<Flashcard>> loadAll() async {
    final words = _wordRepo.list();
    words.sort((a, b) => a.id.compareTo(b.id));
    final stats = {for (var s in _learningRepo.all()) s.wordId: s};
    return words.map((w) {
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
  }
}
