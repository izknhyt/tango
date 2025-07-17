import 'package:tango/flashcard_model.dart';
import 'package:tango/flashcard_repository.dart';
import 'package:tango/word_list_query.dart';
import 'package:tango/services/flashcard_loader.dart';

class FakeFlashcardRepository implements FlashcardRepository {
  final List<Flashcard> _cards;

  FakeFlashcardRepository(this._cards);

  @override
  void setLoader(FlashcardLoader loader) {}

  @override
  Future<List<Flashcard>> loadAll() async => _cards;

  @override
  Future<List<Flashcard>> fetch(WordListQuery query) async {
    return query.apply(_cards);
  }
}
