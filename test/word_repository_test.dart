import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:tango/models/word.dart';
import 'package:tango/services/word_repository.dart';
import 'test_harness.dart' hide setUpAll;

void main() {
  late WordRepository repo;

  setUpAll(() async {
    repo = await WordRepository.open();
  });

  tearDown(() async {
    await Hive.box<Word>(WordRepository.boxName).clear();
  });


  test('adds and fetches word', () async {
    final word = Word(
      id: '1',
      term: 'a',
      reading: 'a',
      description: 'd',
      categoryLarge: 'A',
      categoryMedium: 'B',
      categorySmall: 'C',
      categoryItem: 'D',
      importance: 1,
    );
    await repo.add(word);
    final fetched = repo.get('1');
    expect(fetched?.term, 'a');
  });

  test('lists all words after insertion', () async {
    await repo.add(Word(
      id: '1',
      term: 'a',
      reading: 'b',
      description: 'd',
      categoryLarge: 'A',
      categoryMedium: 'B',
      categorySmall: 'C',
      categoryItem: 'D',
      importance: 2,
    ));
    await repo.add(Word(
      id: '2',
      term: 'b',
      reading: 'a',
      description: 'd',
      categoryLarge: 'A',
      categoryMedium: 'B',
      categorySmall: 'C',
      categoryItem: 'D',
      importance: 1,
    ));

    final words = repo.list();
    expect(words.length, 2);
  });
}
