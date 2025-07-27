
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:tango/models/learning_stat.dart';
import 'package:tango/services/learning_repository.dart';
import 'test_harness.dart';

void main() {
  initTestHarness();



  test('stores and retrieves stats', () async {
    final repo = await LearningRepository.open();
    await repo.markReviewed('1');
    await repo.incrementWrong('1');
    await repo.incrementCorrect('2');
    final stat = repo.get('1');
    expect(stat.viewed, 1);
    expect(stat.wrongCount, 1);
    expect(stat.lastReviewed, isNotNull);
    expect(repo.get('2').correctCount, 1);
  });

  tearDown(() async {
    await Hive.box<LearningStat>(LearningRepository.boxName).clear();
  });
}
