import 'package:hive/hive.dart';

import '../models/learning_stat.dart';

/// Repository for persisting [LearningStat] in Hive.
class LearningRepository {
  static const boxName = 'learning_stat_box_v1';

  final Box<LearningStat> _box;

  LearningRepository._(this._box);

  /// Open the Hive box used for stats.
  static Future<LearningRepository> open() async {
    final Box<LearningStat> box;
    if (Hive.isBoxOpen(boxName)) {
      box = Hive.box(boxName).cast<LearningStat>();
    } else {
      box = await Hive.openBox<LearningStat>(boxName);
    }
    return LearningRepository._(box);
  }

  LearningStat get(String wordId) {
    return _box.get(wordId) ?? LearningStat(wordId: wordId);
  }

  Future<void> put(LearningStat stat) async {
    await _box.put(stat.wordId, stat);
  }

  Future<void> incrementWrong(String wordId) async {
    final stat = get(wordId);
    stat.wrongCount += 1;
    await put(stat);
  }

  Future<void> incrementCorrect(String wordId) async {
    final stat = get(wordId);
    stat.correctCount += 1;
    await put(stat);
  }

  Future<void> markReviewed(String wordId) async {
    final stat = get(wordId);
    stat.lastReviewed = DateTime.now();
    stat.viewed += 1;
    await put(stat);
  }

  List<LearningStat> all() => _box.values.toList();
}
