// lib/flashcard_model.dart

import 'utils/json_extensions.dart';
import 'utils/parsers.dart';

class Flashcard {
  final String id;
  final String term;
  final String? english; // "ー" や "nan" の場合は null として扱う
  final String reading;
  final String description;
  final List<String>? relatedIds;
  final List<String>? tags;
  final String? examExample;
  final String? examPoint;
  final String? practicalTip;
  final String categoryLarge;
  final String categoryMedium;
  final String categorySmall;
  final String categoryItem;
  final double importance; // JSONでは数値だが、念のためnumで受けてdoubleに変換
  final DateTime? lastReviewed;
  final DateTime? nextDue;
  final int wrongCount;
  final int correctCount;

  Flashcard({
    required this.id,
    required this.term,
    this.english,
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
    this.lastReviewed,
    this.nextDue,
    this.wrongCount = 0,
    this.correctCount = 0,
  });

  Flashcard copyWith({
    DateTime? lastReviewed,
    DateTime? nextDue,
    int? wrongCount,
    int? correctCount,
  }) {
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
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextDue: nextDue ?? this.nextDue,
      wrongCount: wrongCount ?? this.wrongCount,
      correctCount: correctCount ?? this.correctCount,
    );
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    final relatedIds = parseStringList(json.getFlexible('relatedIds'));
    final tags = parseStringList(json.getFlexible('tags'));

    return Flashcard(
      id: json.getFlexible('id') as String,
      term: json.getFlexible('term') as String,
      english: parseNullableString(json.getFlexible('english')),
      reading: json.getFlexible('reading') as String,
      description: json.getFlexible('description') as String,
      relatedIds: relatedIds,
      tags: tags,
      examExample: parseNullableString(json.getFlexible('examExample')),
      examPoint: parseNullableString(json.getFlexible('examPoint')),
      practicalTip: parseNullableString(json.getFlexible('practicalTip')),
      categoryLarge: json.getFlexible('categoryLarge') as String,
      categoryMedium: json.getFlexible('categoryMedium') as String,
      categorySmall: json.getFlexible('categorySmall') as String,
      categoryItem: json.getFlexible('categoryItem') as String,
      importance: parseDouble(json.getFlexible('importance')),
      lastReviewed: parseDate(json.getFlexible('lastReviewed')),
      nextDue: parseDate(json.getFlexible('nextDue')),
      wrongCount: (json.getFlexible('wrongCount') as num?)?.toInt() ?? 0,
      correctCount: (json.getFlexible('correctCount') as num?)?.toInt() ?? 0,
    );
  }
}
