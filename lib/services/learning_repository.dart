import 'package:hive/hive.dart';
import 'package:tango/hive_utils.dart';

import '../models/learning_stat.dart';

/// Repository for persisting [LearningStat] in Hive.
class LearningRepository {
  static const boxName = 'learning_stat_box_v1';

  final Box<LearningStat> _box;

  LearningRepository._(this._box);

  /// Open the Hive box used for stats and return a repository.
  ///
  /// Codex: 次のルールで open() を実装してください
  /// 1. アダプター登録は必ず最初に行う
  /// 2. Hive.isBoxOpen(boxName) で開かれていれば
  ///    → `final box = Hive.box<LearningStat>(boxName);`
  ///    を返す
  /// 3. 開かれていなければ
  ///    → `final box = await Hive.openBox<LearningStat>(boxName);`
  ///    を返す
  /// 4. 最後に `return LearningRepository._(box);`
  /// 5. `Hive.openBox` が throw する場合は catch してログだけ出す
  static Future<LearningRepository> open() async {
    if (!Hive.isAdapterRegistered(LearningStatAdapter().typeId)) {
      Hive.registerAdapter(LearningStatAdapter());
    }
    final box = await Hive.openBox<LearningStat>(boxName);
    return LearningRepository._(box);
      Hive.registerAdapter<LearningStat>(LearningStatAdapter());
    }
    try {
      final box = Hive.isBoxOpen(boxName)
          ? Hive.box<LearningStat>(boxName)
          : await Hive.openBox<LearningStat>(boxName);
      return LearningRepository._(box);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to open $boxName: $e');
      rethrow;
    }
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
