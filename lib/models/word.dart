import 'package:hive/hive.dart';
import '../flashcard_model.dart';

part 'word.g.dart';

/// Base word data parsed from JSON and persisted in Hive.
@HiveType(typeId: 2)
class Word extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String term;
  @HiveField(2)
  final String reading;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final List<String>? relatedIds;
  @HiveField(5)
  final List<String>? tags;
  @HiveField(6)
  final String? examExample;
  @HiveField(7)
  final String? examPoint;
  @HiveField(8)
  final String? practicalTip;
  @HiveField(9)
  final String categoryLarge;
  @HiveField(10)
  final String categoryMedium;
  @HiveField(11)
  final String categorySmall;
  @HiveField(12)
  final String categoryItem;
  @HiveField(13)
  final double importance;
  @HiveField(14)
  final String? english;

  Word({
    required this.id,
    required this.term,
    required this.reading,
    required this.description,
    this.relatedIds,
    this.tags,
    this.examExample,
    this.examPoint,
    this.practicalTip,
    required this.categoryLarge,
    required this.categoryMedium,
    required this.categorySmall,
    required this.categoryItem,
    required this.importance,
    this.english,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    final fc = Flashcard.fromJson(json);
    return Word(
      id: fc.id,
      term: fc.term,
      reading: fc.reading,
      description: fc.description,
      relatedIds: fc.relatedIds,
      tags: fc.tags,
      examExample: fc.examExample,
      examPoint: fc.examPoint,
      practicalTip: fc.practicalTip,
      categoryLarge: fc.categoryLarge,
      categoryMedium: fc.categoryMedium,
      categorySmall: fc.categorySmall,
      categoryItem: fc.categoryItem,
      importance: fc.importance,
      english: fc.english,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'term': term,
      'reading': reading,
      'description': description,
      'relatedIds': relatedIds,
      'tags': tags,
      'examExample': examExample,
      'examPoint': examPoint,
      'practicalTip': practicalTip,
      'categoryLarge': categoryLarge,
      'categoryMedium': categoryMedium,
      'categorySmall': categorySmall,
      'categoryItem': categoryItem,
      'importance': importance,
      'english': english,
    };
  }
}

extension WordMapper on Word {
  /// Convert this [Word] to a [Flashcard] for reuse in existing screens.
  Flashcard toFlashcard() {
    return Flashcard(
      id: id,
      term: term,
      english: english,
      reading: reading,
      description: description,
      relatedIds: relatedIds,
      tags: tags,
      examExample: examExample,
      examPoint: examPoint,
      practicalTip: practicalTip,
      categoryLarge: categoryLarge,
      categoryMedium: categoryMedium,
      categorySmall: categorySmall,
      categoryItem: categoryItem,
      importance: importance,
    );
  }
}
