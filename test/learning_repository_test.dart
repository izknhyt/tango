
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:tango/models/learning_stat.dart';
import 'package:tango/services/learning_repository.dart';
import 'test_harness.dart';

void main() {
  initTestHarness();
  late LearningRepository repo;

  setUpAll(() async {
    repo = await LearningRepository.open();
  });


  test('stores and retrieves stats', () async {
    await repo.markReviewed('1');
    await repo.incrementWrong('1');
    await repo.incrementCorrect('2');
    final stat = repo.get('1');
    expect(stat.viewed, 1);
    expect(stat.wrongCount, 1);
    expect(stat.lastReviewed, isNotNull);
    expect(repo.get('2').correctCount, 1);
  });
}
